#ifndef OPENSIM_REGISTERTYPES_OSIMMOCOMARGINOFSTABILITYGOAL_H
#define OPENSIM_REGISTERTYPES_OSIMMOCOMARGINOFSTABILITYGOAL_H

#include "osimMocoMarginOfStabilityGoalDLL.h"

extern "C" {

OSIMMOCOMARGINOFSTABILITYGOAL_API void RegisterTypes_osimMocoMarginOfStabilityGoal();

}

class osimMocoMarginOfStabilityGoalInstantiator {
public:
    osimMocoMarginOfStabilityGoalInstantiator();
private:
    void registerDllClasses();
};

#endif // OPENSIM_REGISTERTYPES_OSIMMOCOMARGINOFSTABILITYGOAL_H
