// The below two lines skip some dll stuff in OpenSim Moco that otherwise 
// seems to interfere with compilation
#define OSIMMOCO_API 
#define OPENSIM_OSIMMOCODLL_H

#ifndef OPENSIM_MOCOPROJECTEDSTABILITYGOAL_H
#define OPENSIM_MOCOPROJECTEDSTABILITYGOAL_H

#include <OpenSim/Moco/osimMoco.h>
#include <OpenSim/Moco/MocoGoal/MocoGoal.h>

namespace OpenSim {

class OSIMMOCO_API MocoProjectedStabilityGoal : public MocoGoal {
    OpenSim_DECLARE_CONCRETE_OBJECT(MocoProjectedStabilityGoal, MocoGoal);

public:
    MocoProjectedStabilityGoal();
    MocoProjectedStabilityGoal(std::string name) : MocoGoal(std::move(name)) { }
    MocoProjectedStabilityGoal(std::string name, double weight) : MocoGoal(std::move(name), weight) { }

protected:
    Mode getDefaultModeImpl() const override { return Mode::Cost; }
    bool getSupportsEndpointConstraintImpl() const override { return true; }
    void initializeOnModelImpl(const Model&) const override;
    void calcIntegrandImpl(
            const IntegrandInput& input, double& integrand) const override;
    void calcGoalImpl(
            const GoalInput& input, SimTK::Vector& cost) const override;

private:

};

} // namespace OpenSim

#endif // OPENSIM_MOCOCUSTOMEFFORTGOAL_H