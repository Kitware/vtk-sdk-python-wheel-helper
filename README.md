# VTK-SDK Python Helper

VTK-SDK Python Helper is a collection of CMake modules to help you build VTK-compatible wheels using the [VTK-SDK](https://docs.vtk.org/en/latest/advanced/wheel_sdks.html)!

## Features

- High-level CMake functions to build VTK modules in a wheel compatible with VTK wheel using the VTK-SDK:
  - Generate a `__init__.py` correctly initializing your module against VTK.
  - Generate a SDK version of your project to then build other VTK modules against it. You can "chain" projects using this.
  - Package runtime dependencies automatically

## Usage

For common usages, simply use FetchContent
```cmake
include(FetchContent)
FetchContent_Declare(vtk-sdk-python-helper
  GIT_REPOSITORY https://github.com/Kitware/vtk-sdk-python-wheel-helper.git
  GIT_TAG        v9.6.0 # matches VTK version
)
FetchContent_MakeAvailable(vtk-sdk-python-helper)
```

Then you get access to the helper's functions, for example:
```cmake
vtksdk_build_modules(${SKBUILD_PROJECT_NAME} MODULES SuperProject::AmazingModule)
vtksdk_generate_package_init(${SKBUILD_PROJECT_NAME} MODULES SuperProject::AmazingModule)
```

See `tests/BasicProject` for more information about building your own module and SDK.
See `tests/packages/build_module` for more information about building your own modules against your **own SDK**!

Other usage example can be fount on [SlicerCore repository](https://github.com/KitwareMedical/SlicerCore).

## Documentation

CMake function documentation can be found in the cmake/*.cmake files.

## Future work

- Support PYI generation using VTK helper script

## License

Apache License, Version 2.0.
See LICENSE file for details.
