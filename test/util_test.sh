#!/usr/bin/env bash

. ${BUILDPACK_TEST_RUNNER_HOME}/lib/test_utils.sh
. ${BUILDPACK_HOME}/bin/util

test_copyDirectories() {
  mkdir -p ${CACHE_DIR}/dir1
  mkdir -p ${CACHE_DIR}/dir2
  copy_directories "dir1 dir2" ${CACHE_DIR} ${BUILD_DIR}
  assertTrue "dir1 should have been copied, but it does not exist in the target directory." "[ -d ${BUILD_DIR}/dir1 ]"
  assertTrue "dir2 should have been copied, but it does not exist in the target directory." "[ -d ${BUILD_DIR}/dir2 ]"
}

test_copyDirectoryThatDoesntExist() {
  mkdir -p ${CACHE_DIR}/dir1
  copy_directories "dir1 dir2" ${CACHE_DIR} ${BUILD_DIR}
  assertTrue "dir1 should have been copied, but it does not exist in the target directory." "[ -d ${BUILD_DIR}/dir1 ]"
  assertTrue "dir2 should not have been copied, but it exists in the target directory." "[ ! -d ${BUILD_DIR}/dir2 ]"
}

test_noDirectories() {
  initialDirectoryCount=$(ls -l | wc -l | sed -E -e 's/\s*//')
  copy_directories "" ${CACHE_DIR} ${BUILD_DIR}
  countDirectories=$(ls -l | wc -l | sed -E -e 's/\s*//')
  assertEquals "${initialDirectoryCount}" "${countDirectories}" 
}

test_invalidBaseDir() {
  directoriesFailure=$(copy_directories "" ${CACHE_DIR}/fake-dir ${BUILD_DIR})
  assertEquals "1" "$?"
  assertEquals "Invalid source directory to copy from. ${CACHE_DIR}/fake-dir" "${directoriesFailure}"
}

test_invalidSourceDir() {
  directoriesFailure=$(copy_directories "" ${CACHE_DIR} ${BUILD_DIR}/fake-dir)
  assertEquals "1" "$?"
  assertEquals "Invalid destination directory to copy to. ${BUILD_DIR}/fake-dir" "${directoriesFailure}"
}

test_sourceDirOverwritesDestDir() {
  mkdir -p ${CACHE_DIR}/dir1
  touch ${CACHE_DIR}/dir1/source
  mkdir -p ${BUILD_DIR}/dir1
  touch ${BUILD_DIR}/dir1/destination
  copy_directories "dir1" ${CACHE_DIR} ${BUILD_DIR}
  assertTrue "dir1 should exist in the source directory, but it does not." "[ -d ${CACHE_DIR}/dir1 ]"
  assertTrue "dir1 should exist in the target directory, but it does not." "[ -d ${BUILD_DIR}/dir1 ]"
  assertTrue "${CACHE_DIR}/dir1/source should exist in the source directory, but it does not." "[ -f ${CACHE_DIR}/dir1/source ]"
  assertTrue "${BUILD_DIR}/dir1/source should exist in the source directory, but it does not." "[ -f ${BUILD_DIR}/dir1/source ]"
  assertTrue "${BUILD_DIR}/dir1/destination should have been removed from the target directory, but it does not." "[ ! -f ${BUILD_DIR}/dir1/destination ]"
}

test_recursiveDirectoriesCopied() {
  mkdir -p ${CACHE_DIR}/dir1/dir2/dir3
  copy_directories "dir1" ${CACHE_DIR} ${BUILD_DIR}
  assertTrue "dir3 should exist in the target directory." "[ -d ${BUILD_DIR}/dir1/dir2/dir3 ]"
}
