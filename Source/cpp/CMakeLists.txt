project(CustomStabilityGoals)

cmake_minimum_required(VERSION 3.2)

# Settings.
# ---------
set(TARGET sitToStand)
set(OPENSIM_INSTALL_DIR $ENV{OPENSIM_HOME}
        CACHE PATH "Top-level directory of OpenSim install")

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
file(GLOB SOURCE_FILES *.h *.cpp)

add_executable(${TARGET} ${SOURCE_FILES})

# Set bin path for executable
cmake_path(GET CMAKE_CURRENT_SOURCE_DIR PARENT_PATH parentPath)
cmake_path(GET parentPath PARENT_PATH rootPath)
set(binPath ${rootPath}/bin)
set_target_properties(sitToStand PROPERTIES
        RUNTIME_OUTPUT_DIRECTORY_RELEASE ${binPath})

# Find boost libraries
set(Boost_DEBUG ON)
find_package(Boost REQUIRED)
include_directories(${Boost_INCLUDE_DIRS})

# Link everything
target_link_libraries(${TARGET} ${Boost_LIBRARIES} ${OpenSim_LIBRARIES})