################################################################################
#
# This is the effective top-level CMakeLists.txt file for the current Pulsar
# library.  You shouldn't have to modify it.
#
################################################################################

#Source our macros
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")
include(OptionMacros)

################################################################################
#
# Read some built-in CMake variables, report their values.
#
################################################################################

option_w_default(CMAKE_BUILD_TYPE Release)
option_w_default(BUILD_SHARED_LIBS TRUE)

bundle_cmake_args(CORE_CMAKE_OPTIONS CMAKE_CXX_COMPILER CMAKE_C_COMPILER
    CMAKE_BUILD_TYPE BUILD_SHARED_LIBS CMAKE_INSTALL_PREFIX)

################################################################################
#
# Handle Pulsar's special options, report their values.
#
################################################################################

option_w_default(BUILD_TESTS TRUE)

################################################################################
#
# Find the dependencies of the project.  Assign their libraries to
# PULSAR_LIBRARY_LIBRARIES and their includes to PULSAR_LIBRARY_INCLUDE_DIRS
#
################################################################################
include(DependencyMacros)
foreach(depend ${PULSAR_LIBRARY_DEPENDS})
    find_dependency(${depend} PULSAR_LIBRARY_INCLUDE_DIRS
                              PULSAR_LIBRARY_LIBRARIES
                              PULSAR_LIBRARY_DEFINITIONS
                              REQUIRED)
endforeach()

################################################################################
#
# Configure some options that tell us where things for the super project are
#
################################################################################

get_filename_component(SUPER_PROJECT_ROOT ${CMAKE_CURRENT_SOURCE_DIR} DIRECTORY)
set(SUPER_PROJECT_SRC ${SUPER_PROJECT_ROOT}/${PULSAR_LIBRARY_NAME})
set(SUPER_PROJECT_TEST ${SUPER_PROJECT_ROOT}/${PULSAR_LIBRARY_NAME}_Test)
set(STAGE_DIR ${CMAKE_BINARY_DIR}/stage)
set(STAGE_INSTALL_DIR ${STAGE_DIR}${CMAKE_INSTALL_PREFIX})
set(TEST_STAGE_DIR ${CMAKE_BINARY_DIR}/test_stage)

################################################################################
#
# Build the main library
#
################################################################################
include(ExternalProject)

ExternalProject_Add(${PULSAR_LIBRARY_NAME}_External
    SOURCE_DIR ${SUPER_PROJECT_SRC}
    CMAKE_ARGS -DSUPER_PROJECT_ROOT=${SUPER_PROJECT_ROOT}
               ${CORE_CMAKE_OPTIONS}
    BUILD_ALWAYS 1
    INSTALL_COMMAND ${CMAKE_MAKE_PROGRAM} install DESTDIR=${STAGE_DIR}
    CMAKE_CACHE_ARGS -DCMAKE_PREFIX_PATH:LIST=${CMAKE_PREFIX_PATH}
                     -DCMAKE_INSTALL_RPATH:LIST=${CMAKE_INSTALL_RPATH}
                     -DCMAKE_CXX_FLAGS:STRING=${CMAKE_CXX_FLAGS}
                     -DCMAKE_MODULE_PATH:LIST=${CMAKE_MODULE_PATH}
                     -DPULSAR_LIBRARY_LIBRARIES:STRING=${PULSAR_LIBRARY_LIBRARIES}
                     -DPULSAR_LIBRARY_INCLUDE_DIRS:STRING=${PULSAR_LIBRARY_INCLUDE_DIRS}
                     -DPULSAR_LIBRARY_DEPENDS:STRING=${PULSAR_LIBRARY_DEPENDS}
)

################################################################################
#
# The generated ProjectConfig.cmake file will need access to some of the CMake #
# tools packaged with PulsarLibraryBase.  Rather than installing it under that #
# library's cmake folder (and cluttering the install dir since presumably      #
# libraries will use PulsarLibraryBase too) we install ourselves.  Before we   #
# do that though we look for an installed version of PulsarLibraryBase.        #
#                                                                              #
################################################################################

find_package(PulsarLibraryBase QUIET)
if(NOT PULSARLIBRARYBASE_FOUND)
    ExternalProject_Add(PulsarLibraryBase_External
        SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/PulsarLibraryBase
        CMAKE_ARGS -DPLB_PREFIX=${CMAKE_CURRENT_SOURCE_DIR}
                   -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX}
        BUILD_ALWAYS 1
        INSTALL_COMMAND ${CMAKE_MAKE_PROGRAM} install DESTDIR=${STAGE_DIR}
    )
else()
    add_library(PulsarLibraryBase_External INTERFACE)
endif()

################################################################################
#                                                                              #
# Build the main library's tests if the user requested them to be built.  Will #
# use the staged ProjectConfig.cmake file.                                     #
#                                                                              #
################################################################################
if(${BUILD_TESTS})
    list(APPEND CMAKE_PREFIX_PATH "${STAGE_INSTALL_DIR}")
    list(APPEND CMAKE_MODULE_PATH "${STAGE_INSTALL_DIR}")
    ExternalProject_Add(${PULSAR_LIBRARY_NAME}_TEST
        SOURCE_DIR ${SUPER_PROJECT_TEST}
        CMAKE_ARGS ${CMAKE_CORE_OPTIONS}
        BUILD_ALWAYS 1
        INSTALL_COMMAND ${CMAKE_MAKE_PROGRAM} install DESTDIR=${TEST_STAGE_DIR}
        CMAKE_CACHE_ARGS -DCMAKE_PREFIX_PATH:LIST=${CMAKE_PREFIX_PATH}
                         -DCMAKE_INSTALL_RPATH:LIST=${CMAKE_INSTALL_RPATH}
                         -DCMAKE_CXX_FLAGS:STRING=${CMAKE_CXX_FLAGS}
                         -DCMAKE_MODULE_PATH:LIST=${CMAKE_MODULE_PATH}
    )
    add_dependencies(${PULSAR_LIBRARY_NAME}_TEST ${PULSAR_LIBRARY_NAME}_External
                                                 PulsarLibraryBase_External
    )

    # This file will allow us to run ctest in the top-level build dir
    # Basically it just defers to the actual top-level CTestTestfile.cmake in the
    # build directory for this project
    file(WRITE ${CMAKE_BINARY_DIR}/CTestTestfile.cmake "subdirs(test_stage)")
endif()

# Install the staging directory
install(DIRECTORY ${STAGE_DIR}/${CMAKE_INSTALL_PREFIX}/
        DESTINATION ${CMAKE_INSTALL_PREFIX} USE_SOURCE_PERMISSIONS)



#####################
# uninstall target
#####################
#configure_file(
#"${CMAKE_CURRENT_SOURCE_DIR}/cmake/cmake_uninstall.cmake.in"
#"${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake"
#IMMEDIATE @ONLY)
#
#add_custom_target(uninstall
#  COMMAND ${CMAKE_COMMAND} -P ${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake)
