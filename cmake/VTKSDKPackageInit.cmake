#[==[.rst:
.. cmake:command:: vtksdk_generate_package_init

  Configure a __init__.py.in file and install in generated package.
  To correctly initialize VTK in the context of VTK-SDK we have to import
  all dependent modules before importing dependent modules.

  - [`INPUT`|`CONTENT`] input file to configure, optional, see below.
  - `MODULES` list of modules to build, must be non-empty.
    Should be the same as the one given to vtksdk_build_modules().

  @PACKAGE_INIT@ will be replaced by VTK and package modules import.
  @PACKAGE_UNINIT@ will be replace by VTK module deletions, so your module won't expose VTK.

  Default file, used if neither INPUT or CONTENT is specified, is:
  ```py
  @PACKAGE_INIT@
  @PACKAGE_UNINIT@
  ```

  Configured file is name __init__.py, and it automatically added to your wheel at your package root folder.

  .. code-block:: cmake

  vtksdk_generate_package_init(<package_name>
    [INPUT <path> | CONTENT <content>]
    [DEPENDENCIES <packages...>]
    MODULES <module>...
    )
#]==]
function(vtksdk_generate_package_init package_name)
  cmake_parse_arguments(PARSE_ARGV 0 arg
    ""
    "INPUT;CONTENT"
    "DEPENDENCIES;MODULES"
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
  set(modules_deps)
  set(modules_name)
  foreach(module IN LISTS arg_MODULES)
    if(module MATCHES "VTK::")
      message(FATAL_ERROR "VTK:: namespace is reserved for VTK owns modules. Please use a different namespace."
        "Note that this is only enforced for the module NAME, not for its LIBRARY_NAME that may start with `vtk`")
    endif()
    vtk_module_get_property(${module} PROPERTY INTERFACE_vtk_module_library_name VARIABLE _name)
    list(APPEND modules_name ${_name})
    vtk_module_get_property(${module} PROPERTY LINK_LIBRARIES VARIABLE _libs)
    list(APPEND modules_deps ${_libs})
  endforeach()
  list(SORT modules_deps)
  list(REMOVE_DUPLICATES modules_deps)
  # ignore our own modules in deps list
  list(REMOVE_ITEM modules_deps ${modules_name})

  # Generate header/footer
  set(PACKAGE_INIT "# BEGIN: Generated automatically by VTK-SDK helper\n")
  set(need_del_vtkmodules FALSE)

  # Generate import of vtkmodules
  foreach(module IN LISTS modules_deps)
    # ignore all non-VTK modules
    message(STATUS ${module})
    if(NOT module MATCHES "^VTK::")
      continue()
    endif()
    # Exclude this module as it is not wrapped in python
    if(module MATCHES "VTK::WrappingPythonCore")
      continue()
    endif()
    vtk_module_get_property(${module} PROPERTY INTERFACE_vtk_module_library_name VARIABLE _name)
    string(APPEND PACKAGE_INIT "import vtkmodules.${_name}\n")
    set(need_del_vtkmodules TRUE)
  endforeach()

  # On windows we have to register third_party directories using os.add_dll_directory
  if(WIN32)
    set(candidates "Path(__file__).parent / \"third_party.libs\"")
    foreach(dep IN LISTS arg_DEPENDENCIES)
      list(APPEND candidates "Path(__file__).parent / \"..\" / \"${dep}\" / \"third_party.libs\"")
    endforeach()
    list(JOIN candidates "," candidates)

    string(APPEND PACKAGE_INIT
      "import os\n"
      "from pathlib import Path\n"
      "for p in [${candidates}]:\n"
      "  if p.is_dir():\n"
      "    os.add_dll_directory(str(p.resolve()))\n"
    )
  endif()

  # Generate import of given dependencies
  foreach(dep IN LISTS arg_DEPENDENCIES)
    string(APPEND PACKAGE_INIT "import ${dep}\n")
  endforeach()

  # Generate import of given modules
  foreach(module IN LISTS arg_MODULES)
    vtk_module_get_property(${module} PROPERTY INTERFACE_vtk_module_library_name VARIABLE _name)
    string(APPEND PACKAGE_INIT "from .${_name} import *\n")
  endforeach()

  # End header
  string(APPEND PACKAGE_INIT "# END: Generated automatically by VTK-SDK helper\n")

  # Generate footer
  set(PACKAGE_UNINIT "# BEGIN: Generated automatically by VTK-SDK helper\n")
  if(need_del_vtkmodules)
    string(APPEND PACKAGE_UNINIT "del vtkmodules\n")
  endif()
  foreach(dep IN LISTS arg_DEPENDENCIES)
    string(APPEND PACKAGE_UNINIT "del ${dep}\n")
  endforeach()
  string(APPEND PACKAGE_UNINIT "# END: Generated automatically by VTK-SDK helper\n")

  # transform arg content into a file as configure_file can only take files
  if(arg_CONTENT)
    set(arg_INPUT "${CMAKE_BINARY_DIR}/vtk-sdk.dir/${package_name}/__init__.py.in")
    file(WRITE "${arg_INPUT}" ${arg_CONTENT})
  endif()

  set(init_file_path "${CMAKE_CURRENT_BINARY_DIR}/vtk-sdk.dir/${package_name}/__init__.py")
  configure_file("${arg_INPUT}" "${init_file_path}" @ONLY)
  install(FILES "${init_file_path}" DESTINATION ${package_name})
endfunction()
