# CHANGELOG

<!-- version list -->

## v1.0.5 (2026-06-15)

### Bug Fixes

- Bump tests VTK version to 9.6.2 to enable Python 3.14 testing
  ([`80f4d4a`](https://github.com/Kitware/vtk-sdk-python-wheel-helper/commit/80f4d4a7a8e120997d1bc0e81ae93b94a75d69a6))

- Enforce CMake 3.27+
  ([`fa6d429`](https://github.com/Kitware/vtk-sdk-python-wheel-helper/commit/fa6d4297560405819774d96e443266c9e515f019))

- Remove warning from CMake 4.3 about path normalisation in install
  ([`4123783`](https://github.com/Kitware/vtk-sdk-python-wheel-helper/commit/41237837da7d6f7a060baefaf209f67cfecc43df))


## v1.0.4 (2026-03-16)

### Bug Fixes

- Propagate correctly external deps in vtksdk_install_modules_sdk
  ([`56c1f88`](https://github.com/Kitware/vtk-sdk-python-wheel-helper/commit/56c1f88512c5dcfc977814beb58643c4dab127a5))


## v1.0.3 (2026-03-12)

### Bug Fixes

- **cmake**: Remove SOVERSION and VERSION from vtk_module_build_modules
  ([`b745455`](https://github.com/Kitware/vtk-sdk-python-wheel-helper/commit/b745455f99f134a47acea143b6b19822a7917612))


## v1.0.2 (2026-03-05)

### Bug Fixes

- Skip unwrapped VTK modules
  ([`18d63d4`](https://github.com/Kitware/vtk-sdk-python-wheel-helper/commit/18d63d4557872a3ea043b6b1897bbc9553e10bf0))

### Testing

- Ensure tests uses the current source of this project
  ([`c49076b`](https://github.com/Kitware/vtk-sdk-python-wheel-helper/commit/c49076ba7fa0b62f444c4a1801a8da79428a842a))


## v1.0.1 (2026-02-27)

### Bug Fixes

- **cmake**: Use the right RPATH on Mac for VTK dylibs
  ([`ec2ff2c`](https://github.com/Kitware/vtk-sdk-python-wheel-helper/commit/ec2ff2cf9a4c1de68d03a187955307e90cb8d2c2))

### Continuous Integration

- Add commitlint
  ([`b2bc09d`](https://github.com/Kitware/vtk-sdk-python-wheel-helper/commit/b2bc09dca6dad71e7de6575c676a61f2bea3a6fe))


## v1.0.0 (2026-02-19)

- Initial Release
