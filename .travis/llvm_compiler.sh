# This file is meant to be included by shell scripts
# to compute the correct version of the LLVM compiler to use.

# Calculate LLVM branch name to retrieve missing files from
SVN_BRANCH="release_$( echo ${LLVM_VERSION} | sed 's/\.//g')"

###############################################################################
# Select the compiler to use to generate LLVM bitcode
###############################################################################
if [ "${LLVM_VERSION}" != "2.9" ]; then
    KLEE_CC=/usr/bin/clang-${LLVM_VERSION}
    KLEE_CXX=/usr/bin/clang++-${LLVM_VERSION}
else
    # Just use pre-built llvm-gcc downloaded earlier
    KLEE_CC=${BUILD_DIR}/llvm-gcc/bin/llvm-gcc
    KLEE_CXX=${BUILD_DIR}/llvm-gcc/bin/llvm-g++
    export C_INCLUDE_PATH=/usr/include/x86_64-linux-gnu
    export CPLUS_INCLUDE_PATH=/usr/include/x86_64-linux-gnu

    # Add symlinks to fix llvm-2.9-dev package so KLEE can configure properly
    # Because of the way KLEE's configure script works this must be a relative
    # symlink, **not** absolute!
    test -L '/usr/lib/llvm-2.9/build/Release' || sudo sh -c 'cd /usr/lib/llvm-2.9/build/ && ln -s ../ Release'
    test -L '/usr/lib/llvm-2.9/build/include' || sudo sh -c 'cd /usr/lib/llvm-2.9/build/ && ln -s ../include include'
fi
