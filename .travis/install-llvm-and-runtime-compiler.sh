#!/bin/bash -x
set -ev

# Install newer compiler to support C++11
sudo add-apt-repository -y ppa:ubuntu-toolchain-r/test
sudo apt-get -qq update
sudo apt-get -qq install g++-5
sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-5 50
sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-5 50

export CC=gcc-5
export CXX=g++-5

sudo apt-get install -y llvm-${LLVM_VERSION} llvm-${LLVM_VERSION}-dev

if [ "${LLVM_VERSION}" == "3.4" ]; then
    sudo apt-get install -y llvm-${LLVM_VERSION}-tools clang-${LLVM_VERSION}
    sudo update-alternatives --install /usr/bin/clang clang /usr/bin/clang-${LLVM_VERSION} 20
    sudo update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-${LLVM_VERSION} 20
else
    echo "Unknown LLVM version ${LLVM_VERSION}"
    exit 1
fi
