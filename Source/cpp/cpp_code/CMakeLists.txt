cmake_minimum_required(VERSION 3.2)
project(OpenSim_MocoMarginOfStabilityGoal)

set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

if (APPLE)
        set(CMAKE_OSX_ARCHITECTURES x86_64)
endif()

find_package(OpenSim REQUIRED HINTS
    "${CMAKE_SOURCE_DIR}/../../../../../../")
include("${OpenSim_USE_FILE}")

add_library(osimMocoMarginOfStabilityGoal SHARED
        MocoMarginOfStabilityGoal.h
        MocoMarginOfStabilityGoal.cpp
        osimMocoMarginOfStabilityGoalDLL.h
        RegisterTypes_osimMocoMarginOfStabilityGoal.h
        RegisterTypes_osimMocoMarginOfStabilityGoal.cpp
        )
add_library(osimMocoProjectedMarginOfStabilityGoal SHARED
        MocoProjectedMarginOfStabilityGoal.h
        MocoProjectedMarginOfStabilityGoal.cpp
        osimMocoProjectedMarginOfStabilityGoalDLL.h
        RegisterTypes_osimMocoProjectedMarginOfStabilityGoal.h
        RegisterTypes_osimMocoProjectedMarginOfStabilityGoal.cpp
        )
add_library(osimMocoWeightedMarginOfStabilityGoal SHARED
        MocoWeightedMarginOfStabilityGoal.h
        MocoWeightedMarginOfStabilityGoal.cpp
        osimMocoWeightedMarginOfStabilityGoalDLL.h
        RegisterTypes_osimMocoWeightedMarginOfStabilityGoal.h
        RegisterTypes_osimMocoWeightedMarginOfStabilityGoal.cpp
        )
target_link_libraries(osimMocoMarginOfStabilityGoal
        osimTools osimExampleComponents osimMoco)
target_link_libraries(osimMocoProjectedMarginOfStabilityGoal
        osimTools osimExampleComponents osimMoco)
target_link_libraries(osimMocoWeightedMarginOfStabilityGoal
        osimTools osimExampleComponents osimMoco)

string(TOUPPER MocoMarginOfStabilityGoal margin_name_upper)
string(TOUPPER MocoProjectedMarginOfStabilityGoal projected_name_upper)
string(TOUPPER MocoWeightedMarginOfStabilityGoal weighted_name_upper)
set_target_properties(osimMocoMarginOfStabilityGoal PROPERTIES
        DEFINE_SYMBOL OSIM${margin_name_upper}_EXPORTS
        )
set_target_properties(osimMocoProjectedMarginOfStabilityGoal PROPERTIES
        DEFINE_SYMBOL OSIM${projected_name_upper}_EXPORTS
        )
set_target_properties(osimMocoWeightedMarginOfStabilityGoal PROPERTIES
        DEFINE_SYMBOL OSIM${weighted_name_upper}_EXPORTS
        )

# Include boost libraries
set(Boost_DEBUG ON)
find_package(Boost REQUIRED)
include_directories(${Boost_INCLUDE_DIRS})
add_executable(main main.cpp)
target_link_libraries(main osimMocoMarginOfStabilityGoal 
        osimMocoProjectedMarginOfStabilityGoal 
        osimMocoWeightedMarginOfStabilityGoal ${Boost_LIBRARIES})

# For Windows: make sure DLLs for dependencies are available.
OpenSimCopyDependencyDLLsForWin(DEP_NAME OpenSim
        DEP_BIN_DIR "${OpenSim_BIN_DIR}")
if(WIN32)
    add_dependencies(osimMocoMarginOfStabilityGoal Copy_OpenSim_DLLs)
    add_dependencies(osimMocoProjectedMarginOfStabilityGoal Copy_OpenSim_DLLs)
    add_dependencies(osimMocoWeightedMarginOfStabilityGoal Copy_OpenSim_DLLs)
endif()

file(COPY  DESTINATION "${CMAKE_CURRENT_BINARY_DIR}")
