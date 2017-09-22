#!/bin/bash

if [[ $# -ne 1 ]]; then
    echo "Syntax: BasicSetup.sh <Name of Library>"
    exit 1
fi

LIBRARY_NAME=$1
SRC_DIR=${LIBRARY_NAME}
TEST_DIR=${LIBRARY_NAME}_Test
CMAKE_FILE=CMakeLists.txt
SRC_LIST=${SRC_DIR}/${CMAKE_FILE}
TEST_LIST=${TEST_DIR}/${CMAKE_FILE}

#Make required folders
mkdir ${SRC_DIR}
mkdir ${TEST_DIR}

#Make top-level CMakeLists.txt
echo "cmake_minimum_required(VERSION 3.1)">${CMAKE_FILE}
echo "project(${LIBRARY_NAME}-superbuild C CXX)">>${CMAKE_FILE}
echo "set(PULSAR_LIBRARY_NAME ${LIBRARY_NAME})">>${CMAKE_FILE}
echo "set(PULSAR_LIBRARY_DEPENDS )">>${CMAKE_FILE}
echo "add_subdirectory(PulsarLibraryBase)">>${CMAKE_FILE}

#Make source-dir CMakeLists.txt
echo "cmake_minimum_required(VERSION 3.1)">${SRC_LIST}
echo "project(${LIBRARY_NAME}-Test CXX)">>${SRC_LIST}
echo "include(TargetMacros)">>${SRC_LIST}
echo "set(${LIBRARY_NAME}_SRCS )">>${SRC_LIST}
echo "set(${LIBRARY_NAME}_INCLUDES )">>${SRC_LIST}
echo "pulsar_add_library(${LIBRARY_NAME} ${LIBRARY_NAME}_SRCS">>${SRC_LIST}
echo "                                   ${LIBRARY_NAME}_INCLUDES">>${SRC_LIST}
echo ")">>${SRC_LIST}

#Make test-dir CMakeLists.txt
echo "cmake_minimum_required(VERSION 3.1)">${TEST_LIST}
echo "project(${LIBRARY_NAME}-Test CXX)">>${TEST_LIST}
echo "find_package(${LIBRARY_NAME} REQUIRED)">>${TEST_LIST}
echo "include(TargetMacros)">>${TEST_LIST}

#Make a .gitignore
echo "${LIBRARY_NAME}.config">.gitignore
echo "${LIBRARY_NAME}.files">>.gitignore
echo "${LIBRARY_NAME}.includes">>.gitignore
echo "*.autosave">>.gitignore
