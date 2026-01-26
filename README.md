# VTK-SDK Python Helper

VTK-SDK Python Helper is a collection of CMake modules to help you build VTK-compatible wheels using the [VTK-SDK](https://docs.vtk.org/en/latest/advanced/wheel_sdks.html)!

## Features

- High-level CMake functions to build VTK modules in a wheel compatible with VTK wheel using the VTK-SDK. See Testing/BasicProject for more information.
- Helper to generate a `__init__.py` correctly initializing your module against VTK.

## Usage

For common usages, simply use FetchContent
```cmake
include(FetchContent)
FetchContent_Declare(vtk-sdk-python-helper
  GIT_REPOSITORY https://github.com/Kitware/vtk-sdk-python-wheel-helper.git
  GIT_TAG        v9.6 # matches VTK version
)
FetchContent_MakeAvailable(vtk-sdk-python-helper)
```

## TODO

- Support PYI generation
- Support SDK generation for user wheels, to chain the chains.

## License

Apache License, Version 2.0.
See LICENSE file for details.
