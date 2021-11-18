#include "MocoProjectedMarginOfStabilityGoal.h"
#include "RegisterTypes_osimMocoProjectedMarginOfStabilityGoal.h"

using namespace OpenSim;

static osimMocoProjectedMarginOfStabilityGoalInstantiator instantiator;

OSIMMOCOPROJECTEDMARGINOFSTABILITYGOAL_API void RegisterTypes_osimMocoProjectedMarginOfStabilityGoal() {
    try {
        Object::registerType(MocoProjectedMarginOfStabilityGoal());
    } catch (const std::exception& e) {
        std::cerr << "ERROR during osimMocoProjectedMarginOfStabilityGoal "
                     "Object registration:\n"
                  << e.what() << std::endl;
    }
}

osimMocoProjectedMarginOfStabilityGoalInstantiator::osimMocoProjectedMarginOfStabilityGoalInstantiator() {
    registerDllClasses();
}

void osimMocoProjectedMarginOfStabilityGoalInstantiator::registerDllClasses() {
    RegisterTypes_osimMocoProjectedMarginOfStabilityGoal();
}
