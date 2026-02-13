cmake_minimum_required(VERSION 3.17...4.0)

project(${SKBUILD_PROJECT_NAME} VERSION ${SKBUILD_PROJECT_VERSION})

find_package(Dummy CONFIG REQUIRED)

include(FetchContent)
FetchContent_Declare(vtk-sdk-python-helper
  SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/../../..
)
FetchContent_MakeAvailable(vtk-sdk-python-helper)

vtksdk_build_modules(${SKBUILD_PROJECT_NAME}
  MODULES Other::Other
  DEPENDENCIES basic_project
)
vtksdk_generate_package_init(${SKBUILD_PROJECT_NAME}
  MODULES Other::Other
  DEPENDENCIES basic_project
)
