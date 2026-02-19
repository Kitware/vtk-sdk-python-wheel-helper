cmake_minimum_required(VERSION 3.17...4.0)

project(${SKBUILD_PROJECT_NAME} VERSION ${SKBUILD_PROJECT_VERSION})

find_package(Dummy CONFIG REQUIRED)

include(VTKSDKPythonWheelHelper)

vtksdk_build_modules(${SKBUILD_PROJECT_NAME}
  MODULES Other::Other
  DEPENDENCIES basic_project
)
vtksdk_generate_package_init(${SKBUILD_PROJECT_NAME}
  MODULES Other::Other
  DEPENDENCIES basic_project
)
