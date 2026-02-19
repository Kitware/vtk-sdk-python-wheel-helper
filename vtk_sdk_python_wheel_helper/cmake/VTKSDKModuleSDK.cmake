
#[==[.rst:
.. cmake:command:: (PRIVATE) _vtksdk_generate_install_root_code

  This generate a code sample inject in the real config module to determine the install tree root.
  The strategy is similar to the one used by CMakePackageConfigHelpers.
  We start at the current list file, i.e. the config module,
  then do get_filename_component(PATH) recusively based on the install location of the config module itself.
#]==]
function(_vtksdk_generate_install_root_code path_prefix output_var)
  # use get_filename_component so old cmake version can find our package
  set(install_prefix_code [[get_filename_component(${CMAKE_FIND_PACKAGE_NAME}_INSTALL_PREFIX "${CMAKE_CURRENT_LIST_FILE}" PATH)]])
  set(_parent "${path_prefix}")
  while(_parent)
    string(APPEND install_prefix_code "\n" [[get_filename_component(${CMAKE_FIND_PACKAGE_NAME}_INSTALL_PREFIX "${${CMAKE_FIND_PACKAGE_NAME}_INSTALL_PREFIX}" PATH)]])
    cmake_path(GET _parent PARENT_PATH _parent)
  endwhile()
  string(APPEND install_prefix_code "\n")

  set("${output_var}" "${install_prefix_code}" PARENT_SCOPE)
endfunction()

function(_vtksdk_check_user_prefixes prefixes_var)
  # Check user prefixes are relative
  set(error FALSE)
  foreach(path IN LISTS ${prefixes_var})
    if(path MATCHES "^([/\\]|[A-Z]:)")
      message(SEND_ERROR "PREFIX_PATHS contains an absolute path, please use relative paths only."
        "Not that relative paths will be evaluated from the install prefix at runtime.")
      set(error TRUE)
    endif()
  endforeach()
  if(error)
    message(FATAL_ERROR "One or more check failed, please check previous log for more information.")
  endif()
endfunction()


#[==[.rst:
.. cmake:command:: vtksdk_install_modules_sdk

  Generate config module, config module version, and scikit-build-core entry-point and install them.

  - `package_name` is the name of the python package, that will be used to name the folder inside site-packages.
  - `COMPATIBILITY` same as CMakePackageConfigHelpers, default to AnyNewerVersion
  - `EXTERNAL_DEPENDENCIES` additional name to find_dependency() from generated config module
  - `CMAKE_MODULES` additional files to add to the CMake folder
  - `CMAKE_MODULES_INCLUDED` additional files to add to the CMake folder, they will be included by the config module automatically
  - `PREFIX_PATHS` additional prefix paths added to the CMAKE_PREFIX_PATH,
        before including the vtk-find-packages script and `EXTERNAL_DEPENDENCIES` find_package
  - `MODULES` list of modules to build, must be non-empty.

.. code-block:: cmake

  vtksdk_install_modules_sdk(<package_name>
    [COMPATIBILITY <AnyNewerVersion|SameMajorVersion|SameMinorVersion|ExactVersion>]
    [EXTERNAL_DEPENDENCIES <package-names>...]
    [CMAKE_MODULES <files...>]
    [CMAKE_MODULES_INCLUDED <files...>]
    [PREFIX_PATHS <paths...>]
    MODULES <module>...
    )
#]==]
function(vtksdk_install_modules_sdk package_name)
  cmake_parse_arguments(PARSE_ARGV 0 arg
    ""
    "COMPATIBILITY"
    "MODULES;EXTERNAL_DEPENDENCIES;CMAKE_MODULES;CMAKE_MODULES_INCLUDED;PREFIX_PATHS"
  )

  if(NOT arg_MODULES)
    message(FATAL_ERROR "MODULES must be defined and a non-empty list of modules.")
  endif()

  set(cmake_install_dir "${package_name}/content/cmake/${package_name}")

  _vtksdk_check_module_names(arg_MODULES package_namespace)
  string(REPLACE ":" "" package_namespace_name "${package_namespace}")

  # Component names are stripped of their namespace
  string(LENGTH "${package_namespace}" namespace_length)

  set(VTKSDK_AVAILABLE_COMPONENTS)
  foreach(module IN LISTS arg_MODULES)
    string(SUBSTRING "${module}" ${namespace_length} -1 component_name)
    list(APPEND VTKSDK_AVAILABLE_COMPONENTS ${component_name})
  endforeach()

  set(VTKSDK_PACKAGE_NAME ${package_name})
  set(VTKSDK_PACKAGE_NAMESPACE ${package_namespace})
  set(VTKSDK_EXTERNAL_PACKAGE_DEPENDS ${EXTERNAL_DEPENDENCIES})
  set(VTKSDK_EXTERNAL_PACKAGE_CMAKE_PREFIX ${arg_PREFIX_PATHS})

  set(VTKSDK_CMAKE_MODULES_INCLUDED)
  foreach(module IN LISTS arg_CMAKE_MODULES_INCLUDED)
    cmake_path(GET module FILENAME name)
    list(APPEND VTKSDK_CMAKE_MODULES_INCLUDED "${name}")
  endforeach()

  _vtksdk_check_user_prefixes(arg_PREFIX_PATHS)
  _vtksdk_generate_install_root_code("${cmake_install_dir}" VTKSDK_EXTERNAL_PACKAGE_INSTALL_PREFIX_CODE)

  set(config_module "${CMAKE_BINARY_DIR}/vtk-sdk.dir/${package_name}/${package_name}-config.cmake")
  configure_file(
    "${CMAKE_CURRENT_FUNCTION_LIST_DIR}/vtkmodule-config.cmake.in"
    "${config_module}"
    @ONLY
  )

  set(compat AnyNewerVersion) # default to AnyNewerVersion
  if(arg_COMPATIBILITY)
    set(compat ${arg_COMPATIBILITY})
  endif()

  include(CMakePackageConfigHelpers)
  set(config_module_version "${CMAKE_BINARY_DIR}/vtk-sdk.dir/${package_name}/${package_name}-config-version.cmake")
  write_basic_package_version_file(${config_module_version}
    VERSION ${SKBUILD_PROJECT_VERSION}
    COMPATIBILITY ${compat}
  )

  install(FILES
    "${config_module}"
    "${config_module_version}"
    ${arg_CMAKE_MODULES}
    ${arg_CMAKE_MODULES_INCLUDED}
    DESTINATION "${cmake_install_dir}"
  )

  set(init_file "${CMAKE_BINARY_DIR}/vtk-sdk.dir/${package_name}/sdk/__init__.py")
  file(WRITE "${init_file}"
      [["""This module serves as a package indicator."""]]
  )

  set(version_file "${CMAKE_BINARY_DIR}/vtk-sdk.dir/${package_name}/sdk/_version.py")
  file(WRITE "${version_file}"
      "__version__ = version = '${SKBUILD_PROJECT_VERSION_FULL}'"
  )

  install(FILES
    "${init_file}"
    "${version_file}"
    DESTINATION "${package_name}"
  )

  set(entry_point_init "${CMAKE_BINARY_DIR}/vtk-sdk.dir/${package_name}/sdk/entry_point/__init__.py")
  file(WRITE "${entry_point_init}"
    [["""This module serves as `cmake.prefix` scikit-build-core entrypoint."""]]
  )

  # Use the CamelCase versions for the entry points so it is case sensitive
  set(entry_point_config_module "${CMAKE_BINARY_DIR}/vtk-sdk.dir/${package_name}/sdk/entry_point/${package_namespace_name}Config.cmake")
  file(WRITE "${entry_point_config_module}"
    "include(\"\${CMAKE_CURRENT_LIST_DIR}/../../${cmake_install_dir}/${package_name}-config.cmake\")"
  )

  set(entry_point_config_module_version "${CMAKE_BINARY_DIR}/vtk-sdk.dir/${package_name}/sdk/entry_point/${package_namespace_name}ConfigVersion.cmake")
  file(WRITE "${entry_point_config_module_version}"
    "include(\"\${CMAKE_CURRENT_LIST_DIR}/../../${cmake_install_dir}/${package_name}-config-version.cmake\")"
  )

  install(FILES
    "${entry_point_init}"
    "${entry_point_config_module}"
    "${entry_point_config_module_version}"
    DESTINATION "${package_name}/cmake"
  )
endfunction()
