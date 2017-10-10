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
    echo "Unknown LLVM version ${LLVM_VERSION}"
    exit 1
fi
