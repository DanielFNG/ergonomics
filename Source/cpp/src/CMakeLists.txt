# Create library
add_library(custom_goals 
    MocoStabilityGoal.cpp "${MocoLowerLevel_SOURCE_DIR}/include/MocoStabilityGoal.hpp"
    MocoMultiJointReactionGoal.cpp "${MocoLowerLevel_SOURCE_DIR}/include/MocoMultiJointReactionGoal.hpp")

# Inlcude directories
target_include_directories(custom_goals PUBLIC ../include)

# Link to OpenSim and Boost
target_link_libraries(custom_goals PRIVATE ${OpenSim_LIBRARIES} Boost::boost)

# IDEs should put the headers in a nice place
source_group(
  TREE "${PROJECT_SOURCE_DIR}/include"
  PREFIX "Header Files"
  FILES ${HEADER_LIST})