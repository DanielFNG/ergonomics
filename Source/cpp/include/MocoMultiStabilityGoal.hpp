#ifndef OPENSIM_MOCOMULTISTABILITYGOAL_H
#define OPENSIM_MOCOMULTISTABILITYGOAL_H

#include <MocoImporter.hpp>

namespace OpenSim {

    class OSIMMOCO_API MocoMultiStabilityGoal : public MocoGoal {
        OpenSim_DECLARE_CONCRETE_OBJECT(MocoMultiStabilityGoal, MocoGoal);

        public:
            MocoMultiStabilityGoal();
            MocoMultiStabilityGoal(std::string name) : MocoGoal(std::move(name)) { 
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

}

#endif