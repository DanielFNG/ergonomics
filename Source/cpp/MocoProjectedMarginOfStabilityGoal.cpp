#include "MocoProjectedMarginOfStabilityGoal.h"
#include <boost/geometry.hpp>
#include <boost/geometry/geometries/point_xy.hpp>

using namespace OpenSim;
using namespace boost::geometry;

typedef model::d2::point_xy<double> point_2d;
typedef model::polygon<point_2d> polygon_2d;

void MocoProjectedMarginOfStabilityGoal::initializeOnModelImpl(const Model&) const {

    // Specify 1 integrand, 1 output, position stage
    setRequirements(1, 1, SimTK::Stage::Dynamics);
}

void MocoProjectedMarginOfStabilityGoal::calcIntegrandImpl(
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
    polygon_2d poly;
    bool empty = true;
    for (int i = 0; i < force_strings.size(); i++) {
        // Compute force at contact point
        const auto& force = getModel().getComponent
            <SmoothSphereHalfSpaceForce>(force_strings[i]);
        Array<double> force_values = force.getRecordValues(input.state);

        // Get contact sphere & associated frame
        const auto& geometries = getModel().getContactGeometrySet();
        const auto& sphere = geometries.get(sphere_strings[i]);
        const auto& frame = sphere.getFrame();

        // Transform sphere location to ground frame
        SimTK::Vec3 ground_point = frame.findStationLocationInGround(
            input.state, sphere.get_location()); 

        // Append the projected 2D point to our polygon
        append(poly.outer(), make<point_2d>(
            ground_point.get(0), ground_point.get(2)));

        // Note that we have at least one point in our polygon
        empty = false;
    }

    // Close the polygon & make sure it is directed clockwise
    correct(poly);

    // If our polygon is non-empty...
    if (!empty) {

        // Compute the centre of the polygon
        point_2d cent;
        centroid(poly, cent);

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

        // Compute the distance between the polygon centre and the extrapolated CoM
        point_2d extrapolated_com;
        assign_values(extrapolated_com, xcom[0], xcom[2]);
        integrand = distance(extrapolated_com, cent);

    } else {
        integrand = 10;
    }
}

void MocoProjectedMarginOfStabilityGoal::calcGoalImpl(
        const GoalInput& input, SimTK::Vector& cost) const {
    cost[0] = input.integral;
}
