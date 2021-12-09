#ifndef OPENSIM_MOCOMARGINOFSTABILITYGOAL_H
#define OPENSIM_MOCOMARGINOFSTABILITYGOAL_H

#include <OpenSim/Moco/osimMoco.h>
#include <OpenSim/Moco/MocoGoal/MocoGoal.h>

namespace OpenSim {

class OSIMMOCO_API MocoMarginOfStabilityGoal : public MocoGoal {
    OpenSim_DECLARE_CONCRETE_OBJECT(MocoMarginOfStabilityGoal, MocoGoal);

public:
    MocoMarginOfStabilityGoal() { }
    MocoMarginOfStabilityGoal(std::string name) : MocoGoal(std::move(name)) { }
    MocoMarginOfStabilityGoal(std::string name, double weight)
            : MocoGoal(std::move(name), weight) { }

protected:
    Mode getDefaultModeImpl() const override { return Mode::Cost; }
    bool getSupportsEndpointConstraintImpl() const override { return true; }
    void initializeOnModelImpl(const Model&) const override;
    void calcIntegrandImpl(
            const IntegrandInput& input, double& integrand) const override;
    void calcGoalImpl(
            const GoalInput& input, SimTK::Vector& cost) const override;

private:
    // Properties
    std::vector<SmoothSphereHalfSpaceForce*> contact_pointers;

};

} // namespace OpenSim

#endif // OPENSIM_MOCOCUSTOMEFFORTGOAL_H
