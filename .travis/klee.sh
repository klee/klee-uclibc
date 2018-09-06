#!/bin/bash -x
# Make sure we exit if there is a failure
set -e
: ${SOLVERS?"Solvers must be specified"}

source ${SRC_DIR}/.travis/llvm_compiler.sh

###############################################################################
# Clone KLEE source code
###############################################################################
git clone https://github.com/klee/klee.git ${SRC_DIR}/klee

###############################################################################
# Testing utils for KLEE
###############################################################################
source ${SRC_DIR}/.travis/testing-utils.sh

cd ${BUILD_DIR}

###############################################################################
# Setting up solvers for KLEE
###############################################################################
source ${SRC_DIR}/.travis/solvers.sh

KLEE_Z3_CONFIGURE_OPTION=""
SOLVER_LIST=$(echo "${SOLVERS}" | sed 's/:/ /')

# Set CMake configure options
for solver in ${SOLVER_LIST}; do
  echo "Setting CMake configuration option for ${solver}"
  case ${solver} in
  Z3)
    echo "Z3"
    KLEE_Z3_CONFIGURE_OPTION="-DENABLE_SOLVER_Z3=TRUE"
    ;;
  *)
    echo "Unknown solver ${solver}"
    exit 1
  esac
done

###############################################################################
# Compile KLEE and run tests
###############################################################################
mkdir klee-build
cd klee-build

KLEE_UCLIBC_CONFIGURE_OPTION="-DENABLE_KLEE_UCLIBC=TRUE -DKLEE_UCLIBC_PATH=${SRC_DIR} -DENABLE_POSIX_RUNTIME=TRUE"

GTEST_SRC_DIR="${BUILD_DIR}/test-utils/googletest-release-1.7.0/"
if [ "X${DISABLE_ASSERTIONS}" == "X1" ]; then
  KLEE_ASSERTS_OPTION="-DENABLE_KLEE_ASSERTS=FALSE"
else
  KLEE_ASSERTS_OPTION="-DENABLE_KLEE_ASSERTS=TRUE"
fi

if [ "X${ENABLE_OPTIMIZED}" == "X1" ]; then
  CMAKE_BUILD_TYPE="RelWithDebInfo"
else
  CMAKE_BUILD_TYPE="Debug"
fi

# Compute CMake build type
cmake \
  -DLLVM_CONFIG_BINARY="/usr/lib/llvm-${LLVM_VERSION}/bin/llvm-config" \
  -DLLVMCC="${KLEE_CC}" \
  -DLLVMCXX="${KLEE_CXX}" \
  -DENABLE_TCMALLOC=OFF \
  ${KLEE_Z3_CONFIGURE_OPTION} \
  ${KLEE_UCLIBC_CONFIGURE_OPTION} \
  -DGTEST_SRC_DIR=${GTEST_SRC_DIR} \
  -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} \
  ${KLEE_ASSERTS_OPTION} \
  -DENABLE_UNIT_TESTS=TRUE \
  -DENABLE_SYSTEM_TESTS=TRUE \
  -DLIT_ARGS="-v" \
  ${SRC_DIR}/klee
make

###############################################################################
# Unit tests
###############################################################################
make unittests

###############################################################################
# lit tests
###############################################################################
make systemtests
