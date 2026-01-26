cmake_minimum_required(VERSION 3.21...3.31)

# Propagate version dermined by scikit-build-core
project(${SKBUILD_PROJECT_NAME}
  VERSION ${SKBUILD_PROJECT_VERSION}
  LANGUAGES CXX
)

include(FetchContent)
FetchContent_Declare(vtk-sdk-python-helper
  SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/../.. # we know about this path
)
FetchContent_MakeAvailable(vtk-sdk-python-helper)

FetchContent_Declare(dependency
  SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/../Dependency # we know about this path
  EXCLUDE_FROM_ALL
)
FetchContent_MakeAvailable(dependency)

set(modules Dummy::Dummy)
vtksdk_build_modules(${SKBUILD_PROJECT_NAME} MODULES ${modules})
vtksdk_generate_package_init(${SKBUILD_PROJECT_NAME} MODULES ${modules})
vtksdk_install_runtimes_deps(${SKBUILD_PROJECT_NAME}
  MODULES ${modules}
  PATHS "${dependency_BINARY_DIR}/bin"
)
