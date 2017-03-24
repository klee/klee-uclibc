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

if [ "X${USE_CMAKE}" == "X1" ]; then
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
else
  for solver in ${SOLVER_LIST}; do
    echo "Setting configuration option for ${solver}"
    case ${solver} in
    Z3)
      echo "Z3"
      KLEE_Z3_CONFIGURE_OPTION="--with-z3=/usr"
      ;;
    *)
      echo "Unknown solver ${solver}"
      exit 1
    esac
  done
fi

###############################################################################
# Compile KLEE and run tests
###############################################################################
mkdir klee-build
cd klee-build

if [ "X${USE_CMAKE}" == "X1" ]; then
  KLEE_UCLIBC_CONFIGURE_OPTION="-DENABLE_KLEE_UCLIBC=TRUE -DKLEE_UCLIBC_PATH=${SRC_DIR} -DENABLE_POSIX_RUNTIME=TRUE"
else
  KLEE_UCLIBC_CONFIGURE_OPTION="--with-uclibc=${SRC_DIR} --enable-posix-runtime"
fi

if [ "X${USE_CMAKE}" == "X1" ]; then
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
else
  # Build KLEE
  # Note: ENABLE_SHARED=0 is required because llvm-2.9 is incorectly packaged
  # and is missing the shared library that was supposed to be built that the build
  # system will try to use by default.
  ${SRC_DIR}/klee/configure --with-llvmsrc=/usr/lib/llvm-${LLVM_VERSION}/build \
              --with-llvmobj=/usr/lib/llvm-${LLVM_VERSION}/build \
              --with-llvmcc=${KLEE_CC} \
              --with-llvmcxx=${KLEE_CXX} \
              ${KLEE_Z3_CONFIGURE_OPTION} \
              ${KLEE_UCLIBC_CONFIGURE_OPTION}
  make  DISABLE_ASSERTIONS=${DISABLE_ASSERTIONS} \
        ENABLE_OPTIMIZED=${ENABLE_OPTIMIZED} \
        ENABLE_SHARED=0
fi

###############################################################################
# Unit tests
###############################################################################
if [ "X${USE_CMAKE}" == "X1" ]; then
  make unittests
else
  # The unittests makefile doesn't seem to have been packaged so get it from SVN
  sudo mkdir -p /usr/lib/llvm-${LLVM_VERSION}/build/unittests/
  svn export  http://llvm.org/svn/llvm-project/llvm/branches/${SVN_BRANCH}/unittests/Makefile.unittest \
      ../Makefile.unittest
  sudo mv ../Makefile.unittest /usr/lib/llvm-${LLVM_VERSION}/build/unittests/

  make unittests \
      DISABLE_ASSERTIONS=${DISABLE_ASSERTIONS} \
      ENABLE_OPTIMIZED=${ENABLE_OPTIMIZED} \
      ENABLE_SHARED=0
fi

###############################################################################
# lit tests
###############################################################################
if [ "X${USE_CMAKE}" == "X1" ]; then
  make systemtests
else
  # Note can't use ``make check`` because llvm-lit is not available
  cd test
  # The build system needs to generate this file before we can run lit
  make lit.site.cfg \
      DISABLE_ASSERTIONS=${DISABLE_ASSERTIONS} \
      ENABLE_OPTIMIZED=${ENABLE_OPTIMIZED} \
      ENABLE_SHARED=0
  cd ../
  lit -v test/
fi
