# Define path to folder to which to copy release mode executables 
set(bin_dir_release "../../../../bin")

# Executables we want to compile
set(APP_FILES
    compareKinematicRMS
    solveAndPrint
    solveAndPrintTracked)

# Create executables in turn
foreach(TARGET IN LISTS APP_FILES)
    add_executable(${TARGET} "${TARGET}.cpp")
    target_link_libraries(${TARGET} PRIVATE custom_goals ${OpenSim_LIBRARIES})
    set_target_properties(${TARGET} PROPERTIES
        RUNTIME_OUTPUT_DIRECTORY_RELEASE ${bin_dir_release})
endforeach()