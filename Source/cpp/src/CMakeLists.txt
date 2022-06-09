# Create library
add_library(custom_goals 
    MocoStabilityGoal.cpp "${MocoLowerLevel_SOURCE_DIR}/include/MocoStabilityGoal.hpp"
    MocoProjectedStabilityGoal.cpp "${MocoLowerLevel_SOURCE_DIR}/include/MocoProjectedStabilityGoal.hpp"
    MocoWeightedStabilityGoal.cpp "${MocoLowerLevel_SOURCE_DIR}/include/MocoWeightedStabilityGoal.hpp"
    MocoMultiStabilityGoal.cpp "${MocoLowerLevel_SOURCE_DIR}/include/MocoMultiStabilityGoal.hpp"
    MocoMultiJointReactionGoal.cpp "${MocoLowerLevel_SOURCE_DIR}/include/MocoMultiJointReactionGoal.hpp")

# Inlcude directories
target_include_directories(custom_goals PUBLIC ../include)

# Link to OpenSim and Boost
target_link_libraries(custom_goals PRIVATE ${OpenSim_LIBRARIES} Boost::boost)

# For IDEs
source_group(
  TREE "${PROJECT_SOURCE_DIR}/include"
  PREFIX "Header Files"
  FILES ${HEADER_LIST})