#[==[.rst:
.. cmake:command:: vtksdk_generate_package_init

  Configure a __init__.py.in file and install in generated package.
  To correctly initialize VTK in the context of VTK-SDK we have to import
  all dependent modules before importing dependent modules.

  Default file, used if neither INPUT or CONTENT is specified, is:
  ```py
  @PACKAGE_INIT@
  @PACKAGE_UNINIT@
  ```

  @PACKAGE_INIT@ will be replaced by VTK and package modules import.
  @PACKAGE_UNINIT@ will be replace by VTK module deletions, so your module won't expose VTK.

  .. code-block:: cmake

  vtksdk_generate_package_init(<package_name>
    [INPUT <path> | CONTENT <content>]
    MODULES <module>...
    )
#]==]
function(vtksdk_generate_package_init package_name)
  cmake_parse_arguments(PARSE_ARGV 0 arg
    ""
    "INPUT;CONTENT;OUTPUT"
    "MODULES"
  )

  if(NOT arg_MODULES)
    message(FATAL_ERROR "MODULES must be defined and a non-empty list of modules.")
  endif()

  if(arg_INPUT AND arg_CONTENT)
    message(FATAL_ERROR "Only one of INPUT or CONTENT must be specified.")
  endif()

  if(NOT arg_INPUT AND NOT arg_CONTENT)
    set(arg_CONTENT "@PACKAGE_INIT@\n@PACKAGE_UNINIT@") # use this when no input or content specified
  endif()

  # Get all dependencies of given modules.
  # LINK_LIBRARIES property contains all DEPENDS and PRIVATE_DEPENDS specified in vtk.module
  set(module_deps)
  foreach(module IN LISTS arg_MODULES)
    vtk_module_get_property(${module} PROPERTY LINK_LIBRARIES VARIABLE _libs)
    list(APPEND module_deps ${_libs})
  endforeach()
  list(SORT module_deps)
  list(REMOVE_DUPLICATES module_deps)

  # Generate header/footer
  set(PACKAGE_INIT "# BEGIN: Generated automatically by VTK-SDK helper\n")
  # Generate import/del of vtkmodules
  foreach(module IN LISTS module_deps)
    string(REPLACE "VTK::" "vtk" _name "${module}")
    string(APPEND PACKAGE_INIT "import vtkmodules.${_name}\n")
  endforeach()
  # Generate import of given modules
  foreach(module IN LISTS arg_MODULES)
    vtk_module_get_property(${module} PROPERTY INTERFACE_vtk_module_library_name VARIABLE _name)
    string(APPEND PACKAGE_INIT "from .${_name} import *\n")
  endforeach()
  string(APPEND PACKAGE_INIT "# END: Generated automatically by VTK-SDK helper\n")
  # End header

  # Generate footer
  set(PACKAGE_UNINIT "# BEGIN: Generated automatically by VTK-SDK helper\n")
  string(APPEND PACKAGE_UNINIT "del vtkmodules\n")
  string(APPEND PACKAGE_UNINIT "# END: Generated automatically by VTK-SDK helper\n")
  # End footer

  # transform arg content into a file as configure_file can only take files
  if(arg_CONTENT)
    set(arg_INPUT "${CMAKE_BINARY_DIR}/vtk-sdk.dir/${package_name}/__init__.py.in")
    file(WRITE "${arg_INPUT}" ${arg_CONTENT})
  endif()

  set(init_file_path "${CMAKE_CURRENT_BINARY_DIR}/vtk-sdk.dir/${package_name}/__init__.py")
  configure_file("${arg_INPUT}" "${init_file_path}" @ONLY)
  install(FILES "${init_file_path}" DESTINATION ${package_name})
endfunction()
