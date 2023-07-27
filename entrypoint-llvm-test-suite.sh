#!/usr/bin/bash

set -x

function configure_build_run {
    # Configure the test suite
    cmake \
        -DCMAKE_GENERATOR=Ninja \
        -DCMAKE_C_COMPILER=/usr/bin/clang \
        -DCMAKE_CXX_COMPILER=/usr/bin/clang++ \
        -C~/test-suite/cmake/caches/O3.cmake \
        ~/test-suite

    # Build the test-suite
    ninja -j30

    # Run the tests with lit:
    lit -j1 -v -o results.json . || true
}

# Build with regular clang
dnf install -y clang clang-libs clang-resource-filesystem llvm llvm-libs

mkdir -pv ~/rawhide
cd ~/rawhide

configure_build_run

# Install and enable the repository that provides the PGO LLVM Toolchain
# See https://llvm.org/docs/HowToBuildWithPGO.html#building-clang-with-pgo
dnf copr enable -y @fedora-llvm-team/llvm-pgo-optimized fedora-rawhide-x86_64
dnf remove -y clang clang-libs clang-resource-filesystem llvm llvm-libs
dnf install -y clang clang-libs clang-resource-filesystem llvm llvm-libs

mkdir -pv ~/pgo
cd ~/pgo

configure_build_run

# Compare the results

/root/test-suite/utils/compare.py \
    --metric exec_time \
    --metric compile_time \
    --metric link_time \
    --lhs-name 16.0.6 \
    --rhs-name 16.0.6-pgo \
    ~/rawhide/results.json vs ~/pgo/results.json > ~/results-1.txt || true

bash
