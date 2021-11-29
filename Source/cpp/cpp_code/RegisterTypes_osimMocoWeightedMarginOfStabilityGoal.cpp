#include "MocoWeightedMarginOfStabilityGoal.h"
#include "RegisterTypes_osimMocoWeightedMarginOfStabilityGoal.h"

using namespace OpenSim;

static osimMocoWeightedMarginOfStabilityGoalInstantiator instantiator;

OSIMMOCOWEIGHTEDMARGINOFSTABILITYGOAL_API void RegisterTypes_osimMocoWeightedMarginOfStabilityGoal() {
    try {
        Object::registerType(MocoWeightedMarginOfStabilityGoal());
    } catch (const std::exception& e) {
        std::cerr << "ERROR during osimMocoWeightedMarginOfStabilityGoal "
                     "Object registration:\n"
                  << e.what() << std::endl;
    }
}

osimMocoWeightedMarginOfStabilityGoalInstantiator::osimMocoWeightedMarginOfStabilityGoalInstantiator() {
    registerDllClasses();
}

void osimMocoWeightedMarginOfStabilityGoalInstantiator::registerDllClasses() {
    RegisterTypes_osimMocoWeightedMarginOfStabilityGoal();
}
