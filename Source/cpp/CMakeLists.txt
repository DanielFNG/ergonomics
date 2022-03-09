project(CustomStabilityGoals)

cmake_minimum_required(VERSION 3.2)

# Settings.
# ---------
set(OPENSIM_INSTALL_DIR $ENV{OPENSIM_HOME}
        CACHE PATH "Top-level directory of OpenSim install")
message(STATUS "OI ${OPENSIM_INSTALL_DIR}")

# OpenSim uses C++11 language features, and we need >=14 for Boost.
set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF) # This is needed to stop some weird error

# Settings for compilation on Apple
if (APPLE)
        set(CMAKE_OSX_ARCHITECTURES x86_64)
endif()

# Find and hook up to OpenSim.
# ----------------------------
find_package(OpenSim REQUIRED PATHS "${OPENSIM_INSTALL_DIR}")

# Configure this project.
# -----------------------
file(GLOB GOALS Goals/*.h Goals/*.cpp)
file(GLOB UTILS Utils/*.h Utils/*.cpp)
file(GLOB SOURCE *.h *.cpp)

message(STATUS "OI: ${SOURCE}")

# Set bin path for executable
cmake_path(GET CMAKE_CURRENT_SOURCE_DIR PARENT_PATH parentPath)
cmake_path(GET parentPath PARENT_PATH rootPath)
set(binPath ${rootPath}/bin)

# Find boost libraries
set(Boost_DEBUG ON)
find_package(Boost REQUIRED)
include_directories(${Boost_INCLUDE_DIRS})

# Create executables - not sure this is done right, think all executables
# are compiled against all headers and all source cpp files which obviously
# isn't necessary. Fine for now.
foreach(source_file ${SOURCE})
        get_filename_component(source_name ${source_file} NAME)
        add_executable(${source_name} ${source_file} ${GOALS} ${UTILS})
        set_target_properties(${source_name} PROPERTIES
                RUNTIME_OUTPUT_DIRECTORY_RELEASE ${binPath})
        target_link_libraries(${source_name} ${Boost_LIBRARIES} ${OpenSim_LIBRARIES})
endforeach(source_file ${SOURCE})
