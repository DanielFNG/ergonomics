#ifndef OPENSIM_REGISTERTYPES_OSIMMOCOPROJECTEDMARGINOFSTABILITYGOAL_H
#define OPENSIM_REGISTERTYPES_OSIMMOCOPROJECTEDMARGINOFSTABILITYGOAL_H

#include "osimMocoProjectedMarginOfStabilityGoalDLL.h"

extern "C" {

OSIMMOCOPROJECTEDMARGINOFSTABILITYGOAL_API void RegisterTypes_osimMocoProjectedMarginOfStabilityGoal();

}

class osimMocoProjectedMarginOfStabilityGoalInstantiator {
public:
    osimMocoProjectedMarginOfStabilityGoalInstantiator();
private:
    void registerDllClasses();
};

#endif // OPENSIM_REGISTERTYPES_OSIMMOCOPROJECTEDMARGINOFSTABILITYGOAL_H
