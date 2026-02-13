#[==[.rst:
.. cmake:command:: vtksdk_install_runtimes_deps

  Find runtime dependencies using `file(GET_RUNTIME_DEPENDENCIES)` at install-time.
  They will be installed in "<package-name>/third_party.libs".

  - `package_name` is the name of the python package, that will be used to name the folder inside site-packages.
  - `MODULES` list of modules to build, must be non-empty.
  - `PRE_INCLUDE_REGEXES`, `PRE_EXCLUDE_REGEXES`, `POST_INCLUDE_REGEXES`,
    `POST_EXCLUDE_REGEXES`, `POST_INCLUDE_FILES` and `POST_EXCLUDE_FILES`
    are forwarded to underlying `file(GET_RUNTIME_DEPENDENCIES)`

  .. code-block:: cmake

  vtksdk_build_modules(<package_name>
    MODULES <module>...
    [PATHS <paths>...]
    [PRE_INCLUDE_REGEXES <regexes>...]
    [PRE_EXCLUDE_REGEXES <regexes>...]
    [POST_INCLUDE_REGEXES <regexes>...]
    [POST_EXCLUDE_REGEXES <regexes>...]
    [POST_INCLUDE_FILES <files>...]
    [POST_EXCLUDE_FILES <files>...]
    )
#]==]
function(vtksdk_install_runtimes_deps package_name)
  cmake_parse_arguments(PARSE_ARGV 0 arg
    ""
    "DESTINATION"
    "MODULES;PATHS;PRE_INCLUDE_REGEXES;PRE_EXCLUDE_REGEXES;POST_INCLUDE_REGEXES;POST_EXCLUDE_REGEXES;POST_INCLUDE_FILES;POST_EXCLUDE_FILES"
  )

  if(NOT arg_MODULES)
    message(FATAL_ERROR "MODULES must be defined and a non-empty list of modules.")
  endif()

  set(MODULES_LIBS)
  foreach(module IN LISTS arg_MODULES)
    if(module MATCHES "VTK::")
      message(FATAL_ERROR "VTK:: namespace is reserved for VTK owns modules. Please use a different namespace."
        "Note that this is only enforced for the module NAME, not for its LIBRARY_NAME that may start with `vtk`")
    endif()
    list(APPEND MODULES_LIBS "$<TARGET_FILE:${module}>")
  endforeach()
  list(JOIN MODULES_LIBS "\n" MODULES_LIBS) # replace semicolons with spaces

  # Exclude VTK lib directory. Uses VTK::CommonCore as the source of truth, should be fine
  # Note that building multiple time in a row with --no-clean may result in VTK not being excluded
  find_package(VTK CONFIG REQUIRED COMPONENTS CommonCore)
  set(VTK_EXCLUDE_LIST "\"$<TARGET_FILE_DIR:VTK::CommonCore>\"")
  # Do not install libs and symlinks that may have been resolved indirectly
  set(SELF_EXCLUDE_LIST "\"^${CMAKE_CURRENT_BINARY_DIR}/${package_name}/\"")

  # Add vtk search directory for Windows. Note that this is done to ensure everything went fine
  list(APPEND arg_PATHS "$<TARGET_FILE_DIR:VTK::CommonCore>")
  list(JOIN arg_PATHS "\n" SEARCH_PATHS)

  # Configure and add script to install code
  set(script_path "${CMAKE_CURRENT_BINARY_DIR}/vtk-sdk.dir/${package_name}/install-deps.cmake")
  configure_file(
    ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/install-deps.cmake.in
    ${script_path}
    @ONLY)
  # Resolves generator expressions
  file(GENERATE
    OUTPUT "${script_path}-$<CONFIG>"
    INPUT "${script_path}"
  )
  install(SCRIPT "${script_path}-$<CONFIG>")
endfunction()
