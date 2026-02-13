cmake_minimum_required(VERSION 3.21...3.31)

# Propagate version dermined by scikit-build-core
project(${SKBUILD_PROJECT_NAME}
  VERSION ${SKBUILD_PROJECT_VERSION}
  LANGUAGES CXX
)

option(BUILD_SDK "If ON, build Summy-SDK instead of Dummy runtime" OFF)

include(FetchContent)
FetchContent_Declare(vtk-sdk-python-helper
  SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/../.. # we know about this path
)
FetchContent_MakeAvailable(vtk-sdk-python-helper)

find_package(Dependency REQUIRED)

set(layout Runtime)
if(BUILD_SDK)
  set(layout SDK)
endif()

set(modules Dummy::Dummy)

vtksdk_build_modules(${SKBUILD_PROJECT_NAME}
  MODULES ${modules}
  LAYOUT ${layout}
)

if(BUILD_SDK)
  # Install dependencies required to consume SlicerCore as a SDK
  vtksdk_install_modules_sdk(${SKBUILD_PROJECT_NAME}
    MODULES ${modules}
  )
else()
  vtksdk_generate_package_init(${SKBUILD_PROJECT_NAME} MODULES ${modules})
  vtksdk_install_runtimes_deps(${SKBUILD_PROJECT_NAME}
    MODULES ${modules}
    PATHS "${dependency_BINARY_DIR}/bin"
  )
endif()
