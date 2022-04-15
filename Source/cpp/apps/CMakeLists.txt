# Define path to folder to which to copy release mode executables 
set(bin_dir_release "../../../../bin")

add_executable(optimise4D optimise4D.cpp)
target_link_libraries(optimise4D PRIVATE custom_goals ${OpenSim_LIBRARIES})
set_target_properties(optimise4D PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY_RELEASE ${bin_dir_release})

add_executable(optimise7D optimise7D.cpp)
target_link_libraries(optimise7D PRIVATE custom_goals ${OpenSim_LIBRARIES})
set_target_properties(optimise7D PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY_RELEASE ${bin_dir_release})