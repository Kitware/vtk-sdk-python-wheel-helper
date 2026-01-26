vtk_module_add_module(Dummy::Dummy
  CLASSES vtkDummy
  HEADERS_SUBDIR vtkDummy
)
vtk_module_link(Dummy::Dummy PRIVATE Dependency::Dependency)
