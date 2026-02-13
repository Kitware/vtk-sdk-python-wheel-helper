
#[==[.rst:
.. cmake:command:: _vtksdk_check_module_names

  Enforces correct module identifiers:
    - Module namespace must start with a capital letter [A-Z], followed by any number of word character ([A-Za-z0-9-_]).
    - Module must contain an unique namespace (:: only once).
    - Module namespace must not be VTK::
    - Module name must start with a letter [a-zA-Z], followed by any number of word character ([A-Za-z0-9-_])
    - All modules share the same namespace
#]==]
function(_vtksdk_check_module_names modules_var namespace_output_var)
  # All errors are defered so user get them all at once,
  # but we will want to stop CMake processing at the end of the function
  set(error FALSE)

  set(package_namespace)
  foreach(module IN LISTS ${modules_var})
    # Check that module has a well-formed identifier
    if(NOT module MATCHES "^[A-Z][A-Za-z0-9_-]*::[a-zA-Z][A-Za-z0-9_-]*$")
      message(SEND_ERROR "\"${module}\" is not a valid module identifier:\n"
        "  Module namespace must start with a capital letter [A-Z], followed by any number of word character ([A-Za-z0-9-_]).\n"
        "  Module must contain an unique namespace (:: only once).\n"
        "  Module name must start with a letter [a-zA-Z], followed by any number of word character ([A-Za-z0-9-_])"
      )
      set(error TRUE)
    endif()

    # Do let user use VTK:: namespace
    if(module MATCHES "^VTK::")
      message(SEND_ERROR "VTK:: namespace is reserved for VTK owns modules. Please use a different namespace."
        "Note that this is only enforced for the module NAME, not for its LIBRARY_NAME that may start with `vtk`")
      set(error TRUE)
    endif()

    # Ensure that all modules use the same namespace
    # This is mainly done to make generated config module easier to write.
    string(REGEX MATCH "^[A-Z][A-Za-z0-9_-]*::" _namespace ${module})
    if(NOT package_namespace)
      set(package_namespace "${_namespace}")
    endif()
    if(NOT package_namespace STREQUAL _namespace)
      message(SEND_ERROR "All modules must use the same namespace!"
        "${module} namespace conflict with previously found namespace ${package_namespace}."
        "Note that module namespace will be used as the CMake package indentifier, for find_package!")
      set(error TRUE)
    endif()
  endforeach()

  if(error)
    message(FATAL_ERROR "One or more check failed, please check previous log for more information.")
  endif()

  set("${namespace_output_var}" "${package_namespace}" PARENT_SCOPE)
endfunction()
