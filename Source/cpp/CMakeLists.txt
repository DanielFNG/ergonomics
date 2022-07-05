cmake_minimum_required(VERSION 3.16)

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

        # Force x86_64 compilation on Apple M-series chips
        # if (APPLE)
        #         set(CMAKE_OSX_ARCHITECTURES x86_64)
        # endif()

        # Support folders in IDEs
        set_property(GLOBAL PROPERTY USE_FOLDERS ON)
endif()

# Find OpenSim - should work if the OpenSim bin folder is in the PATH
find_package(OpenSim REQUIRED)

# Find Boost
set(Boost_DEBUG ON)
find_package(Boost REQUIRED)

# Add library
add_subdirectory(src)

# Add executables
add_subdirectory(apps)
