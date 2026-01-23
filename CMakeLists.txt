cmake_minimum_required(VERSION 3.21)

if(CMAKE_CURRENT_SOURCE_DIR STREQUAL CMAKE_SOURCE_DIR)
    message(FATAL_ERROR "This file must never be configured as a top level project!"
        "It is intended to be embedded in another project using Git sumodules or FetchContent.")
endif()

if(NOT DEFINED SKBUILD_PROJECT_NAME)
    message(FATAL_ERROR "This file must only be used when build scikit-build-core projects.")
endif()

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/CMake)

# Include all modules by default
include(VTKSDKModuleBuilder)
include(VTKSDKPackageInit)
