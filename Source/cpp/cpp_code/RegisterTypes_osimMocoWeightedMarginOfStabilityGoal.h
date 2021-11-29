#ifndef OPENSIM_REGISTERTYPES_OSIMMOCOWEIGHTEDMARGINOFSTABILITYGOAL_H
#define OPENSIM_REGISTERTYPES_OSIMMOCOWEIGHTEDMARGINOFSTABILITYGOAL_H

#include "osimMocoWeightedMarginOfStabilityGoalDLL.h"

extern "C" {

OSIMMOCOWEIGHTEDMARGINOFSTABILITYGOAL_API void RegisterTypes_osimMocoWeightedMarginOfStabilityGoal();

}

class osimMocoWeightedMarginOfStabilityGoalInstantiator {
public:
    osimMocoWeightedMarginOfStabilityGoalInstantiator();
private:
    void registerDllClasses();
};

#endif // OPENSIM_REGISTERTYPES_OSIMMOCOWEIGHTEDMARGINOFSTABILITYGOAL_H
