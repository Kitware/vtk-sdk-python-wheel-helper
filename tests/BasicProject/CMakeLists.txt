cmake_minimum_required(VERSION 3.21...3.31)

# Propagate name and version determined from scikit-build-core (pyproject metadata)
# If you want the version to be dynamically set depending on git tags or whatever,
# please take a look at scikit-build documentation about version provider:
# Don't forget to take a look at the pyproject.toml file for more information.
project(${SKBUILD_PROJECT_NAME}
  VERSION ${SKBUILD_PROJECT_VERSION}
  LANGUAGES CXX
)

# This project goes hard-mode and has a native third-party.
# Native dependencies need to be packaged, see vtksdk_install_runtimes_deps below
find_package(Dependency REQUIRED)

# List of our VTK-based modules to build
# While not forced to use a variable, this makes everything easier as most helper's functions will
# ask for the full modules list. This example only has a single module.
set(modules Dummy::Dummy)

# Helper can build two types of wheels:
# - A runtime wheel: the default, it only installs what is required to import the library and use it from Python code
# - An SDK-wheel: the equivalent of the VTK-SDK, but for YOUR wheel! It makes a more standard CMake installation and
#   sets up a scikit-build-core entry point so you can depend on it as you do with the vtk-sdk.
option(BUILD_SDK "If ON, build Dummy-SDK instead of Dummy runtime" OFF)
set(layout Runtime)
if(BUILD_SDK)
  set(layout SDK)
endif()

# ------------------------------------------------------------------------------
# The rest of the code uses the vtk-sdk-python-helper CMake function,
# for more information about these functions please take a look at
# vtk-sdk-python-helper's documentation!
# ------------------------------------------------------------------------------

message(STATUS "Module path : ${CMAKE_MODULE_PATH}")
message(STATUS "Prefix path : ${CMAKE_PREFIX_PATH}")

# It does nothing automatically, think of it as a "CMake library"!
include(VTKSDKPythonWheelHelper)

# This is the main command from the helper.
# It will find VTK automatically, look for vtk.module files, then trigger modules build and wrapping.
vtksdk_build_modules(${SKBUILD_PROJECT_NAME}
  MODULES ${modules}
  LAYOUT ${layout}
)

# We will call different utilities depending on the layout and expected usage
if(BUILD_SDK)
  # This function generates the missing pieces to consume the wheel as an SDK:
  # - CMake config module (supporting find_package components, that are your modules!)
  # - CMake config module version
  # - scikit-build-core entry-point glue
  # It also install them at the right locations.
  # Note that you still have to specify the following in your SDK pyproject.toml!
  #   [project.entry-points."cmake.prefix"]
  #   PackageName = "<package-name>_sdk.cmake"
  vtksdk_install_modules_sdk(${SKBUILD_PROJECT_NAME}
    MODULES ${modules}
  )

  # You may perform additional install here
  # for example slicer-core installs its public dependencies (ITK, vtkAddon) here
  # as they are required to build against slicer-core-sdk!
else()
  # When building the runtime-only wheel, we need a `__init__.py` for our package.
  # The VTK-SDK gymnastics is kinda tricky so this is a high-level function
  # that generates a simple "import all specified modules" package init that takes
  # care of handling platform-specific things, such as windows os.add_dll_directory
  # vtk imports to have access to classes' parents types etc.
  # vtk dependency is implicit, but if you rely on another vtk-sdk based sdk, such
  # as the slicer-core-sdk, you will have to specify `DEPENDENCIES slicer-core`.
  vtksdk_generate_package_init(${SKBUILD_PROJECT_NAME} MODULES ${modules})

  # We also have to install runtime dependencies.
  # Note that PATHS is only for Windows, for Linux and Mac, R[UN]PATHS must be used.
  vtksdk_install_runtimes_deps(${SKBUILD_PROJECT_NAME}
    MODULES ${modules}
    PATHS "$<TARGET_FILE_DIR:Dependency::Dependency>"
  )
endif()

# For a real-world example, please take a look at the SlicerCore project CMakeLists.txt!
