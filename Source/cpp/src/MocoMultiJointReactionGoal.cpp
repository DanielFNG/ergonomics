// A revised version of the MocoJointReactionGoal that allows for the specification
// of multiple terms, with an overall weighted cost. 

#include <MocoMultiJointReactionGoal.hpp>

#include <OpenSim/Moco/MocoUtilities.h>

#include <OpenSim/Simulation/Model/Model.h>

using namespace OpenSim;

MocoMultiJointReactionGoal::MocoMultiJointReactionGoal() {}

void MocoMultiJointReactionGoal::setJointPathAndWeight(const std::string& jointPath, const double jointWeight)
{
    joint_paths.push_back(jointPath);
    joint_weights.push_back(jointWeight);
}

void MocoMultiJointReactionGoal::initializeOnModelImpl(const Model& model) const {
    
    for (int i = 0; i < joint_paths.size(); ++i)
    {
        SimTK::ReferencePtr<const Joint> one_m_joint;
        one_m_joint = &model.getComponent<Joint>(joint_paths[i]);
        m_joint.push_back(std::move(one_m_joint)); // Need to use std::move due to SimTK::ReferencePtr behaviour
        SimTK::ReferencePtr<const Frame> one_m_frame;
        one_m_frame = &m_joint[i]->getParentFrame();
        m_frame.push_back(std::move(one_m_frame)); 
    }

    // Now we assign the 

    m_denominator = model.getTotalMass(model.getWorkingState());
    const double gravityAccelMagnitude = model.get_gravity().norm();
    if (gravityAccelMagnitude > SimTK::SignificantReal) {
        m_denominator *= gravityAccelMagnitude;
    }

    // If user provided no reaction measure names, then set all measures to
    // to be minimized. Otherwise, loop through user-provided measure names
    // and check that they are all accepted measures.
    std::vector<std::string> reactionMeasures;
    std::vector<std::string> allowedMeasures = {"moment-x", "moment-y",
            "moment-z", "force-x", "force-y", "force-z"};
    reactionMeasures = allowedMeasures;

    // Loop through all reaction measures to minimize and get the
    // corresponding SpatialVec indices and weights.
    for (const auto& measure : reactionMeasures) {
        if (measure == "moment-x") {
            m_measureIndices.push_back({0, 0});
        } else if (measure == "moment-y") {
            m_measureIndices.push_back({0, 1});
        } else if (measure == "moment-z") {
            m_measureIndices.push_back({0, 2});
        } else if (measure == "force-x") {
            m_measureIndices.push_back({1, 0});
        } else if (measure == "force-y") {
            m_measureIndices.push_back({1, 1});
        } else if (measure == "force-z") {
            m_measureIndices.push_back({1, 2});
        }
    }

    setRequirements(1, 1);
}

void MocoMultiJointReactionGoal::calcIntegrandImpl(
        const IntegrandInput& input, SimTK::Real& integrand) const {

    getModel().realizeAcceleration(input.state);
    const auto& ground = getModel().getGround();

    // Zero the integrand result
    integrand = 0;

    // For each input joint...
    for (int joint = 0; joint < joint_paths.size(); ++joint)
    {

        // Compute the reaction loads on the parent or child frame.
        SimTK::SpatialVec reactionInGround;
        reactionInGround = m_joint[joint]->calcReactionOnParentExpressedInGround(input.state);

        // Re-express the reactions into the proper frame and repackage into a new
        // SpatialVec.
        SimTK::Vec3 moment;
        SimTK::Vec3 force;
        if (m_frame[joint].get() == &getModel().getGround()) {
            moment = reactionInGround[0];
            force = reactionInGround[1];
        } else {
            moment = ground.expressVectorInAnotherFrame(
                    input.state, reactionInGround[0], *m_frame[joint]);
            force = ground.expressVectorInAnotherFrame(
                    input.state, reactionInGround[1], *m_frame[joint]);
        }
        SimTK::SpatialVec reaction(moment, force);

        // Compute cost
        double result = 0;
        for (int i = 0; i < (int)m_measureIndices.size(); ++i)
        {
            const auto index = m_measureIndices[i];
            result += 1.0 * pow(reaction[index.first][index.second], 2);
        }
        integrand += joint_weights[joint] * result;

    }
}

void MocoMultiJointReactionGoal::printDescriptionImpl() const {
    log_cout("not implemented");
}