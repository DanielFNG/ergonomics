#ifndef OPENSIM_MOCOWEIGHTEDSTABILITYGOAL_H
#define OPENSIM_MOCOWEIGHTEDSTABILITYGOAL_H

#include <MocoImporter.hpp>

namespace OpenSim {

    class OSIMMOCO_API MocoWeightedStabilityGoal : public MocoGoal {
        OpenSim_DECLARE_CONCRETE_OBJECT(MocoWeightedStabilityGoal, MocoGoal);

        public:
            MocoWeightedStabilityGoal();
            MocoWeightedStabilityGoal(std::string name) : MocoGoal(std::move(name)) {}
            MocoWeightedStabilityGoal(std::string name, double weight) : 
                MocoGoal(std::move(name), weight) {}

        protected:
            Mode getDefaultModeImpl() const override { return Mode::Cost; }
            bool getSupportsEndpointConstraintImpl() const override { return true; }
            void initializeOnModelImpl(const Model&) const override;
            void calcIntegrandImpl(
                    const IntegrandInput& input, double& integrand) const override;
            void calcGoalImpl(
                    const GoalInput& input, SimTK::Vector& cost) const override;

        };

}

#endif