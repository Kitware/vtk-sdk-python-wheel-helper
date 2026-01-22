# VTK-SDK Python Helper

VTK-SDK Python Helper is a collection of CMake modules to help you build VTK-compatible wheels using the [VTK-SDK](https://docs.vtk.org/en/latest/advanced/wheel_sdks.html)!

## Usage

For common usages, simply use FetchContent
```cmake
include(FetchContent)
FetchContent_Declare(
  vtk-sdk-python-helper
  GIT_REPOSITORY https://github.com/Kitware/vtk-sdk-python-wheel-helper.git
  GIT_TAG        v9.6 # matches VTK version!
)
FetchContent_MakeAvailable(vtk-sdk-python-helper)
```

Alternatively, all scripts, and their functions are standalone, so you can fetch them using `file(DOWNLOAD)`.

## License

Apache License, Version 2.0.
See LICENSE file for details.
