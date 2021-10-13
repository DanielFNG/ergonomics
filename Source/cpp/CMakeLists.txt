cmake_minimum_required(VERSION 3.2)
project(OpenSim_MocoMarginOfStabilityGoal)

set(CMAKE_CXX_STANDARD 11)

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
target_link_libraries(osimMocoMarginOfStabilityGoal
        osimTools osimExampleComponents osimMoco)

string(TOUPPER MocoMarginOfStabilityGoal example_name_upper)
set_target_properties(osimMocoMarginOfStabilityGoal PROPERTIES
        DEFINE_SYMBOL OSIM${example_name_upper}_EXPORTS
        )

# Include boost libraries
set(Boost_DEBUG ON)
find_package(Boost REQUIRED)
include_directories(${Boost_INCLUDE_DIRS})
add_executable(main main.cpp)
target_link_libraries(main osimMocoMarginOfStabilityGoal ${Boost_LIBRARIES})

# For Windows: make sure DLLs for dependencies are available.
OpenSimCopyDependencyDLLsForWin(DEP_NAME OpenSim
        DEP_BIN_DIR "${OpenSim_BIN_DIR}")
if(WIN32)
    add_dependencies(osimMocoMarginOfStabilityGoal Copy_OpenSim_DLLs)
endif()

file(COPY  DESTINATION "${CMAKE_CURRENT_BINARY_DIR}")
