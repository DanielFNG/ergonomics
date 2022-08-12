#ifndef OPENSIM_MOCOMULTIJOINTREACTIONGOAL_H
#define OPENSIM_MOCOMULTIJOINTREACTIONGOAL_H

#include <MocoImporter.hpp>
#include <OpenSim/Simulation/SimbodyEngine/Joint.h>

namespace OpenSim {
    
class OSIMMOCO_API MocoMultiJointReactionGoal : public MocoGoal {
OpenSim_DECLARE_CONCRETE_OBJECT(MocoMultiJointReactionGoal, MocoGoal);
public:
    MocoMultiJointReactionGoal();
    MocoMultiJointReactionGoal(std::string name) : MocoGoal(std::move(name)) {};

    /** Set the model path to the joint whose reaction load(s) will be
    minimized. */
    void setJointPathAndWeight(const std::string& jointPath, const double jointWeight);

protected:
    void initializeOnModelImpl(const Model&) const override;
    void calcIntegrandImpl(
            const IntegrandInput& input, SimTK::Real& integrand) const override;
    void calcGoalImpl(
            const GoalInput& input, SimTK::Vector& cost) const override {
        cost[0] = input.integral / m_denominator;
    }
    void printDescriptionImpl() const override;

private:   

    mutable std::vector<std::string> joint_paths;
    mutable std::vector<double> joint_weights;
    mutable double m_denominator;
    mutable std::vector<SimTK::ReferencePtr<const Joint>> m_joint;
    mutable std::vector<SimTK::ReferencePtr<const Frame>> m_frame;
    mutable std::vector<std::pair<int, int>> m_measureIndices;
};

} // namespace OpenSim

#endif // OPENSIM_MOCOMULTIJOINTREACTIONGOAL_H