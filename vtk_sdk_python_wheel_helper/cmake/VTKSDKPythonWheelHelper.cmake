if(NOT DEFINED SKBUILD_PROJECT_NAME)
    message(FATAL_ERROR "This file must only be used when build scikit-build-core projects.")
endif()

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR})

# Include other modules
include(VTKSDKCommon)
include(VTKSDKModuleBuilder)
include(VTKSDKModuleSDK)
include(VTKSDKPackageInit)
include(VTKSDKInstallRuntimeDeps)
