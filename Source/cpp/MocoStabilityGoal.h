// The below two lines skip some dll stuff in OpenSim Moco that otherwise 
// seems to interfere with compilation
#define OSIMMOCO_API 
#define OPENSIM_OSIMMOCODLL_H

#ifndef OPENSIM_MOCOSTABILITYGOAL_H
#define OPENSIM_MOCOSTABILITYGOAL_H

#include <OpenSim/Moco/osimMoco.h>
#include <OpenSim/Moco/MocoGoal/MocoGoal.h>

namespace OpenSim {

class OSIMMOCO_API MocoStabilityGoal : public MocoGoal {
    OpenSim_DECLARE_CONCRETE_OBJECT(MocoStabilityGoal, MocoGoal);

public:
    MocoStabilityGoal();
    MocoStabilityGoal(std::string name) : MocoGoal(std::move(name)) { 
        constructProperties();
            }

    void setMOSWeight(double weight) 
    {   
        set_mos_weight(weight);
    }
    void setPMOSWeight(double weight)
    {
        set_pmos_weight(weight);
    }
    void setWMOSWeight(double weight)
    {
        set_wmos_weight(weight);
    }

protected:
    Mode getDefaultModeImpl() const override { return Mode::Cost; }
    bool getSupportsEndpointConstraintImpl() const override { return true; }
    void initializeOnModelImpl(const Model&) const override;
    void calcIntegrandImpl(
            const IntegrandInput& input, double& integrand) const override;
    void calcGoalImpl(
            const GoalInput& input, SimTK::Vector& cost) const override;

private:
    OpenSim_DECLARE_PROPERTY(mos_weight, double,
        "The weight corresponding to the Margin of Stability term.");
    OpenSim_DECLARE_PROPERTY(pmos_weight, double, 
        "The weight corresponding to the Projected Margin of Stability term.");
    OpenSim_DECLARE_PROPERTY(wmos_weight, double,
        "The weight corresponding to the Weighted Margin of Stability term.");

    void constructProperties();

};

} // namespace OpenSim

#endif // OPENSIM_MOCOCUSTOMEFFORTGOAL_H