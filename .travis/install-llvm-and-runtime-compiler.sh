#!/bin/bash -x
set -ev

sudo apt-get install -y llvm-${LLVM_VERSION} llvm-${LLVM_VERSION}-dev

if [ "${LLVM_VERSION}" == "3.4" ]; then
    sudo apt-get install -y llvm-${LLVM_VERSION}-tools clang-${LLVM_VERSION}
    sudo update-alternatives --install /usr/bin/clang clang /usr/bin/clang-${LLVM_VERSION} 20
    sudo update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-${LLVM_VERSION} 20
else
    echo "Unknown LLVM version ${LLVM_VERSION}"
    exit 1
fi
