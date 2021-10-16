#ifndef OPENSIM_OSIMMOCOMARGINOFSTABILITYGOALDLL_H
#define OPENSIM_OSIMMOCOMARGINOFSTABILITYGOALDLL_H

#ifndef _WIN32
    #define OSIMMOCOMARGINOFSTABILITYGOAL_API
#else
    #ifdef OSIMMOCOMARGINOFSTABILITYGOAL_EXPORTS
        #define OSIMMOCOMARGINOFSTABILITYGOAL_API __declspec(dllexport)
    #else
        #define OSIMMOCOMARGINOFSTABILITYGOAL_API __declspec(dllimport)
    #endif
#endif

#endif // OPENSIM_OSIMMOCOMARGINOFSTABILITYGOALDLL_H