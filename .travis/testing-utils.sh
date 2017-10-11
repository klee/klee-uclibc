#!/bin/bash -x
# Make sure we exit if there is a failure
set -e

mkdir ${BUILD_DIR}/test-utils/
cd ${BUILD_DIR}/test-utils/

# The New CMake build system just needs the GTest sources regardless
# of LLVM version.
wget https://github.com/google/googletest/archive/release-1.7.0.zip
unzip release-1.7.0.zip
