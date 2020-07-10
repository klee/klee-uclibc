# This file is meant to be included by shell scripts
# to compute the correct version of the LLVM compiler to use.

# Calculate LLVM branch name to retrieve missing files from
SVN_BRANCH="release_$( echo ${LLVM_VERSION} | sed 's/\.//g')"

###############################################################################
# Select the compiler to use to generate LLVM bitcode
###############################################################################
KLEE_CC=/usr/bin/clang-${LLVM_VERSION}
KLEE_CXX=/usr/bin/clang++-${LLVM_VERSION}
