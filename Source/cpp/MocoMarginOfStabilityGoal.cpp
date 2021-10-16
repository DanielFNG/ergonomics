#include "MocoMarginOfStabilityGoal.h"
#include <boost/geometry.hpp>
#include <boost/geometry/geometries/point_xy.hpp>

using namespace OpenSim;
using namespace boost::geometry;

typedef model::d2::point_xy<double> point_2d;
typedef model::polygon<point_2d> polygon_2d;

void MocoMarginOfStabilityGoal::initializeOnModelImpl(const Model&) const {

    // Specify 1 integrand, 1 output, position stage
    setRequirements(1, 1, SimTK::Stage::Dynamics);
}

void MocoMarginOfStabilityGoal::calcIntegrandImpl(
        const IntegrandInput& input, double& integrand) const {
    
    // Update model positions
    getModel().realizeDynamics(input.state);

    /*

    const auto& force = getModel().getComponent
        <SmoothSphereHalfSpaceForce>("contactHeel_l");
    Array<double> force_values = force.getRecordValues(input.state);

    const auto& geometries = getModel().getContactGeometrySet();
    const auto& ground_transform = 
        geometries.get("heel_l").getFrame().getTransformInGround(input.state);

    SimTK::Vec3 ground_point = 
        ground_transform * geometries.get("heel_l").get_location();

    integrand = ground_point[1];

    */

    // Access required contact forces.
    std::vector<std::string> force_strings = {
        "contactHeel_l", "contactHeel_r", "contactFront_l", "contactFront_r", "chair_l", "chair_r"
    };

    // Access required contact geometries
    std::vector<std::string> sphere_strings = {
        "heel_l", "heel_r", "front_l", "front_r", "butt_l", "butt_r"
    };
        
    // Create BoS polygon
    
    polygon_2d poly;
    bool empty = true;
    for (int i = 0; i < force_strings.size(); i++) {
        // Compute force at contact point
        const auto& force = getModel().getComponent
            <SmoothSphereHalfSpaceForce>(force_strings[i]);
        Array<double> force_values = force.getRecordValues(input.state);

        // If we register a vertical force, this point is active, so we append 
        // it to our BoS polygon
        if (force_values[1] > force.get_constant_contact_force()) {
            // Get contact spheres
            const auto& geometries = getModel().getContactGeometrySet();

            // Compute transformation from sphere frame to ground frame
            const auto& ground_transform = 
                geometries.get(sphere_strings[i]).getFrame().getTransformInGround(input.state);

            // Transform sphere location to ground frame
            SimTK::Vec3 ground_point = 
                ground_transform * geometries.get(sphere_strings[i]).get_location();

            // Append the projected 2D point to our polygon
            append(poly.outer(), make<point_2d>(
                ground_point.get(0), ground_point.get(2)));

            // Note that we have at least one point in our polygon
            empty = false;
        }
    }

    // Close the polygon & make sure it is directed clockwise
    correct(poly);

    // If our polygon is non-empty...
    if (!empty) {

        // Compute the centre of the polygon
        point_2d cent;
        centroid(poly, cent);

        // Compute the CoM of the model given the current state
        double Mass = 0.0;
        double com[3] = {0.0, 0.0, 0.0};
        SimTK::Vec3 vec;
        const auto& bs = getModel().getBodySet();
        for (int i = 0; i < bs.getSize(); i++) {
            const auto& body = bs.get(i);
            const SimTK::Vec3 body_com = body.get_mass_center();
            vec = body.findStationLocationInGround(input.state, body_com);
            Mass += body.get_mass();
            com[0] += body.get_mass() * vec[0];
            com[1] += body.get_mass() * vec[1];
            com[2] += body.get_mass() * vec[2];
        }
        com[0] /= Mass;
        com[1] /= Mass;
        com[2] /= Mass;

        // Compute the distance between the polygon centre and the CoM projection
        point_2d com_projection;
        assign_values(com_projection, com[0], com[2]);
        integrand = distance(com_projection, cent);

    } else {
        integrand = 10;
    }
}

void MocoMarginOfStabilityGoal::calcGoalImpl(
        const GoalInput& input, SimTK::Vector& cost) const {
    cost[0] = input.integral;
}