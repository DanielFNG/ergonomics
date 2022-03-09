#include "MocoStabilityGoal.h"
#include <boost/geometry.hpp>
#include <boost/geometry/geometries/point_xy.hpp>

using namespace OpenSim;
using namespace boost::geometry;

typedef model::d2::point_xy<double> point_2d;
typedef model::polygon<point_2d> polygon_2d;

MocoStabilityGoal::MocoStabilityGoal() {
    constructProperties();
}

void MocoStabilityGoal::constructProperties() {
    constructProperty_mos_weight(0.0);
    constructProperty_pmos_weight(0.0);
    constructProperty_wmos_weight(0.0);
}

void MocoStabilityGoal::initializeOnModelImpl(const Model&) const {

    // Specify 1 integrand, 1 output, position stage
    setRequirements(1, 1, SimTK::Stage::Dynamics);
}

void MocoStabilityGoal::calcIntegrandImpl(
        const IntegrandInput& input, double& integrand) const {
    
    // Update model positions
    getModel().realizeDynamics(input.state);

    // Access required contact forces.
    std::vector<std::string> force_strings = {
        "chair_r", "chair_l", "contactHeel_l", "contactFront_l", "contactFront_r", "contactHeel_r"
    };

    // Access required contact geometries
    std::vector<std::string> sphere_strings = {
        "butt_r", "butt_l", "heel_l", "front_l", "front_r", "heel_r"
    };

    // Get model weight
    double model_weight = getModel().getGravity().get(1)*getModel().getTotalMass(input.state);
        
    // Create BoS polygon
    std::vector<double> vertex_x = {0.0, 0.0, 0.0, 0.0, 0.0, 0.0};
    std::vector<double> vertex_z = {0.0, 0.0, 0.0, 0.0, 0.0, 0.0};
    std::vector<double> vertex_weights = {0.0, 0.0, 0.0, 0.0, 0.0, 0.0};
    polygon_2d bos_poly;
    polygon_2d pbos_poly;
    bool empty = true;
    for (int i = 0; i < force_strings.size(); i++) {
        // Compute force at contact point
        const auto& force = getModel().getComponent
            <SmoothSphereHalfSpaceForce>(force_strings[i]);
        Array<double> force_values = force.getRecordValues(input.state);

        // Assign vertex weight
        vertex_weights[i] = force_values[1]/model_weight;

        // Get contact sphere & associated frame
        const auto& geometries = getModel().getContactGeometrySet();
        const auto& sphere = geometries.get(sphere_strings[i]);
        const auto& frame = sphere.getFrame();

        // Transform sphere location to ground frame
        SimTK::Vec3 ground_point = frame.findStationLocationInGround(
            input.state, sphere.get_location());

        // Append the projected 2D point to our PBoS polygon no matter what
        append(pbos_poly.outer(), make<point_2d>(
            ground_point.get(0), ground_point.get(2)));
            
        // Assign vertex position - incase order changes later
        vertex_x[i] = ground_point.get(0);
        vertex_z[i] = ground_point.get(2);

        // If we register a vertical force, this point is active, so we append 
        // it to our BoS polygon
        if (force_values[1] > force.get_constant_contact_force()) {

            // Append the projected 2D point to our polygon
            append(bos_poly.outer(), make<point_2d>(
                ground_point.get(0), ground_point.get(2)));

            // Note that we have at least one point in our bos polygon
            empty = false;
        }
    }

    // Close the polygons & make sure they are directed clockwise
    correct(bos_poly);
    correct(pbos_poly);

    // Compute the position & velocity of the CoM of the model given the current state
    double Mass = 0.0;
    double com[3] = {0.0, 0.0, 0.0};
    double com_v[3] = {0.0, 0.0, 0.0};
    SimTK::Vec3 vec, vel;
    const auto& bs = getModel().getBodySet();
    for (int i = 0; i < bs.getSize(); i++) {
        const auto& body = bs.get(i);
        const SimTK::Vec3 body_com = body.get_mass_center();
        vec = body.findStationLocationInGround(input.state, body_com);
        vel = body.findStationVelocityInGround(input.state, body_com);
        Mass += body.get_mass();
        com[0] += body.get_mass() * vec[0];
        com[1] += body.get_mass() * vec[1];
        com[2] += body.get_mass() * vec[2];
        com_v[0] += body.get_mass() * vel[0];
        com_v[1] += body.get_mass() * vel[1];
        com_v[2] += body.get_mass() * vel[2];
    }
    com[0] /= Mass;
    com[1] /= Mass;
    com[2] /= Mass;
    com_v[0] /= Mass;
    com_v[1] /= Mass;
    com_v[2] /= Mass;

    // Compute extrapolated centre of mass
    double g = 9.80665;
    double xcom[3] = {0.0, 0.0, 0.0};
    xcom[0] = com[0] + com_v[0]/sqrt(g/com[1]);
    xcom[1] = com[1] + com_v[1]/sqrt(g/com[1]);
    xcom[2] = com[2] + com_v[2]/sqrt(g/com[1]);

    // Create a point representing the xcom
    point_2d extrapolated_com;
    assign_values(extrapolated_com, xcom[0], xcom[2]);

    // Compute the centre of the pbos polygon
    point_2d pbos_cent;
    centroid(pbos_poly, pbos_cent);

    // Compute the centre of the weighted polygon
    std::vector<double> wcent = {0.0, 0.0};
    double total_weight = 0;
    for (int i = 0; i < force_strings.size(); i++) {
        total_weight = total_weight + vertex_weights[i];
        wcent[0] = wcent[0] + vertex_x[i]*vertex_weights[i];
        wcent[1] = wcent[1] + vertex_z[i]*vertex_weights[i];
    }
    wcent[0] = wcent[0]/total_weight;
    wcent[1] = wcent[1]/total_weight;

    // Compute the distance between the pbos centre and the xcom
    double pmos_term = distance(extrapolated_com, pbos_cent);

    // Compute the distance between the bos centre and the xcom
    point_2d bos_cent;
    double mos_term = 10.0;  // Default value if BoS is empty
    // If our polygon is non-empty...
    if (!empty) {

        // Compute the centre of the bos polygon
        centroid(bos_poly, bos_cent);

        // Compute the distance between the bos centre and the extrapolated CoM
        mos_term = distance(extrapolated_com, bos_cent);
    }

    // Compute the distance between the wmos centre and the xcom
    double wmos_term = sqrt(pow((wcent[0] - xcom[0]), 2) + pow((wcent[1] - xcom[2]), 2));

    // Return the integrand
    integrand = mos_term * get_mos_weight() + pmos_term * get_pmos_weight() + wmos_term * get_wmos_weight();
}

void MocoStabilityGoal::calcGoalImpl(
        const GoalInput& input, SimTK::Vector& cost) const {
    cost[0] = input.integral;
}