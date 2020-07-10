#!/bin/bash -x
set -ev

sudo apt-get install -y llvm-${LLVM_VERSION} llvm-${LLVM_VERSION}-dev
sudo apt-get install -y clang-${LLVM_VERSION} llvm-${LLVM_VERSION}-tools
sudo update-alternatives --install /usr/bin/clang clang /usr/bin/clang-${LLVM_VERSION} 20
sudo update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-${LLVM_VERSION} 20
