#include "MocoMarginOfStabilityGoal.h"
#include "RegisterTypes_osimMocoMarginOfStabilityGoal.h"

using namespace OpenSim;

static osimMocoMarginOfStabilityGoalInstantiator instantiator;

OSIMMOCOMARGINOFSTABILITYGOAL_API void RegisterTypes_osimMocoMarginOfStabilityGoal() {
    try {
        Object::registerType(MocoMarginOfStabilityGoal());
    } catch (const std::exception& e) {
        std::cerr << "ERROR during osimMocoMarginOfStabilityGoal "
                     "Object registration:\n"
                  << e.what() << std::endl;
    }
}

osimMocoMarginOfStabilityGoalInstantiator::osimMocoMarginOfStabilityGoalInstantiator() {
    registerDllClasses();
}

void osimMocoMarginOfStabilityGoalInstantiator::registerDllClasses() {
    RegisterTypes_osimMocoMarginOfStabilityGoal();
}
