################################################################################
#
# Macros for defining new targets.
#
# General definitions so they aren't defined for each function:
#     name      : The name of the target
#     flags     : These are compile-time flags to pass to the compiler
#     includes  : The directories containing include files for the target
#     libraries : The libraries the target needs to link against
#
################################################################################

include(CTest)
enable_testing()

#Little trick so we always know this directory even when we are in a function
set(DIR_OF_TARGET_MACROS ${CMAKE_CURRENT_LIST_DIR})

#
# This is code factorization for the next few functions.
#
function(pulsar_set_up_target __name __flags __includes __libraries __install)
    target_link_libraries(${__name} PRIVATE "${__libraries}")
    target_compile_options(${__name} PRIVATE "${__flags}")
    target_include_directories(${__name} PRIVATE ${SUPER_PROJECT_ROOT}
                                                 "${__includes}")
    install(TARGETS ${__name} DESTINATION ${__install})
endfunction()

#
# Macro for building a library
#
# Syntax: pulsar_add_library(<Name> <Sources> <Headers> <Flags>
#     - Name : The name to use for the library, result will be libName.so
#     - Sources : A list of source files to compile to form the library.  Should
#                 be relative paths.
#     - Headers : A list of header files that should be considered the public
#                 API of the library.  Should be relative paths.
#     - Flags   : These are flags needed to compile the library in addition to
#                 those provided by this library's dependencies.
#
function(pulsar_add_library __name __srcs __headers __flags)
    set(__srcs_copy ${${__srcs}})
    set(__headers_copy ${${__headers}})
    make_full_paths(__srcs_copy)
    make_full_paths(__headers_copy)
    add_library(${__name} SHARED ${__srcs_copy})
    pulsar_set_up_target(${__name} "${__flags}" "${PULSAR_LIBRARY_INCLUDE_DIRS}"
                         "${PULSAR_LIBRARY_LIBRARIES}" lib/${__name})
    set(PULSAR_LIBRARY_NAME ${__name})
    set(PULSAR_LIBRARY_HEADERS ${${__headers}})
    configure_file("${DIR_OF_TARGET_MACROS}/PulsarTargetConfig.cmake.in"
                    ${__name}Config.cmake @ONLY)
    install(FILES ${CMAKE_BINARY_DIR}/${__name}Config.cmake
            DESTINATION share/cmake/${__name})
    install(FILES ${__headers_copy} DESTINATION include/${__name})
endfunction()

#
# Defines a test.  This is the base call.  You'll likely be using one of the
#    functions that follows this declaration.
#
# Syntax: pulsar_add_test(<name> <test_file> <flags> <includes> <libraries>
#                  <install>)
#    - test_file : This is the file containing the test
#    - target    : This is the CMake target providing the includes, flags,
#                  libraries, etc. that is being tested.
#    - install   : The directory the test will be installed into
function(pulsar_add_test __name __test_file __target __install)
    SET(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)
    add_executable(${__name} ${__test_file})
    pulsar_set_up_target(${__name} "" "${__target}" "${__target}"
                         "${__install}")
    add_test(NAME ${__name} COMMAND $<TARGET_FILE:${__name}>)
endfunction()

#
# Specializes add_test to C++ unit tests.  Assumes the test is coded up in a
# file with the same name as the test and a ".cpp" extension and that all of
# the dependencies are wrapped up in a CMake target with the name __target.
#
function(add_cxx_unit_test __name __target)
    pulsar_add_test(${__name} ${__name}.cpp ${__target} UnitTests)
endfunction()
