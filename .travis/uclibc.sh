#!/bin/bash -x
# Make sure we exit if there is a failure
set -e

source ${SRC_DIR}/.travis/llvm_compiler.sh

cd ${SRC_DIR}
./configure --make-llvm-lib --with-cc "${KLEE_CC}" --with-llvm-config /usr/bin/llvm-config-${LLVM_VERSION}
make
