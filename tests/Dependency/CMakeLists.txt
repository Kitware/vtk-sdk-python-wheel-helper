cmake_minimum_required(VERSION 3.21...3.31)

project(Dependency VERSION 1.0.0)

include(GenerateExportHeader)

add_library(Dependency SHARED Dependency.cpp)
generate_export_header(Dependency
  EXPORT_FILE_NAME ${CMAKE_CURRENT_BINARY_DIR}/DependencyExport.hpp
)
target_include_directories(Dependency PUBLIC
  $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}> $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}>
  $<INSTALL_INTERFACE:include>
)

add_library(Dependency::Dependency ALIAS Dependency)

install(TARGETS Dependency EXPORT DependencyTargets)
install(FILES
    ${CMAKE_CURRENT_SOURCE_DIR}/Dependency.hpp
    ${CMAKE_CURRENT_BINARY_DIR}/DependencyExport.hpp
  DESTINATION include
)

install(EXPORT DependencyTargets
  DESTINATION lib/cmake/Dependency
  NAMESPACE Dependency::
)

include(CMakePackageConfigHelpers)

configure_package_config_file(
  ${CMAKE_CURRENT_SOURCE_DIR}/CMake/DependencyConfig.cmake.in
  ${CMAKE_CURRENT_BINARY_DIR}/DependencyConfig.cmake
  INSTALL_DESTINATION lib/cmake/Dependency
)

write_basic_package_version_file(
  ${CMAKE_CURRENT_BINARY_DIR}/DependencyConfigVersion.cmake
  VERSION ${PROJECT_VERSION}
  COMPATIBILITY SameMajorVersion
)

install(FILES
  ${CMAKE_CURRENT_BINARY_DIR}/DependencyConfigVersion.cmake
  ${CMAKE_CURRENT_BINARY_DIR}/DependencyConfig.cmake
  DESTINATION lib/cmake/Dependency
)
