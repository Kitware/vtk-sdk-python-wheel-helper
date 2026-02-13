vtk_module_find_package(PACKAGE Dependency
  PRIVATE_IF_SHARED
)

vtk_module_add_module(Dummy::Dummy
  CLASSES vtkDummy
)

vtk_module_link(Dummy::Dummy PRIVATE Dependency::Dependency)
