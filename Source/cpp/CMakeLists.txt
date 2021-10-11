cmake_minimum_required(VERSION 3.2)
project(OpenSim_MocoCustomEffortGoal)

set(CMAKE_CXX_STANDARD 11)

find_package(OpenSim REQUIRED HINTS
    "${CMAKE_SOURCE_DIR}/../../../../../../")
include("${OpenSim_USE_FILE}")

add_library(osimMocoCustomEffortGoal SHARED
        MocoCustomEffortGoal.h
        MocoCustomEffortGoal.cpp
        osimMocoCustomEffortGoalDLL.h
        RegisterTypes_osimMocoCustomEffortGoal.h
        RegisterTypes_osimMocoCustomEffortGoal.cpp
        )
target_link_libraries(osimMocoCustomEffortGoal
        osimTools osimExampleComponents osimMoco)

string(TOUPPER MocoCustomEffortGoal example_name_upper)
set_target_properties(osimMocoCustomEffortGoal PROPERTIES
        DEFINE_SYMBOL OSIM${example_name_upper}_EXPORTS
        )

add_executable(exampleMocoCustomEffortGoal exampleMocoCustomEffortGoal.cpp)
target_link_libraries(exampleMocoCustomEffortGoal osimMocoCustomEffortGoal)

# For Windows: make sure DLLs for dependencies are available.
OpenSimCopyDependencyDLLsForWin(DEP_NAME OpenSim
        DEP_BIN_DIR "${OpenSim_BIN_DIR}")
if(WIN32)
    add_dependencies(osimMocoCustomEffortGoal Copy_OpenSim_DLLs)
endif()

file(COPY  DESTINATION "${CMAKE_CURRENT_BINARY_DIR}")
