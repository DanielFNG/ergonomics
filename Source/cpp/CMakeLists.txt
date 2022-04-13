cmake_minimum_required(VERSION 3.19)

# Project name & versioning
project(MocoLowerLevel VERSION 0.1
        DESCRIPTION "Lower-level optimiser for ergonomics project."
        LANGUAGES CXX)

# Protect from being included elsewhere
if (CMAKE_PROJECT_NAME STREQUAL PROJECT_NAME)

        # OpenSim uses C++11 language features, and we need >=14 for Boost.
        set(CMAKE_CXX_STANDARD 14)
        set(CMAKE_CXX_STANDARD_REQUIRED ON)
        set(CMAKE_CXX_EXTENSIONS OFF)

        # Settings for compilation on Apple
        if (APPLE)
                set(CMAKE_OSX_ARCHITECTURES x86_64)
        endif()

        # Support folders in IDEs
        set_property(GLOBAL PROPERTY USE_FOLDERS ON)
endif()

# Find OpenSim
set(OPENSIM_INSTALL_DIR $ENV{OPENSIM_HOME} CACHE PATH "Top-level directory of OpenSim install")
find_package(OpenSim REQUIRED PATHS "${OPENSIM_INSTALL_DIR}")

# Find Boost
set(Boost_DEBUG ON)
find_package(Boost REQUIRED)

# Add library
add_subdirectory(src)

# Add executables
add_subdirectory(apps)
