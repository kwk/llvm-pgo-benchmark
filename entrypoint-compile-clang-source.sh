#!/usr/bin/bash

set -x

function configure_build_run {
    local name=$1
    local build_dir=~/llvm-project/build-$name
    cmake \
        -B ~/llvm-project/build-$name \
        -S ~/llvm-project \
        -DCMAKE_C_COMPILER=clang \
        -DCMAKE_CXX_COMPILER=clang++ \
        -DBUILD_SHARED_LIBS=ON \
        -DLLVM_OPTIMIZED_TABLEGEN=ON \
        -DCMAKE_BUILD_TYPE=Debug \
        -DLLVM_USE_SPLIT_DWARF=ON \
        -DLLVM_ENABLE_PROJECTS="clang;clang-tools-extra" \
        -DCMAKE_EXPORT_COMPILE_COMMANDS=1 \
        ~/llvm-project/llvm

    # Find a huge file to compile properly in the compile_commands.json
    local obj=$(jq '.[] | select(.file|test(".*/llvm-project/clang/lib/AST/ExprConstant.cpp"))' $build_dir/compile_commands.json)
    local command=$(echo $obj | jq '.command' -r)
    local directory=$(echo $obj | jq '.directory' -r)
    echo "RUNNING: $cmd"
    pushd $directory
    multitime -n 10 $(command)
    popd
}

# Build with regular clang
dnf install -y clang clang-libs clang-resource-filesystem llvm llvm-libs

set -e
cd multitime
make -f Makefile.bootstrap
autoupdate 
./configure
make install
cd ..
set +e

configure_build_run rawhide

# Install and enable the repository that provides the PGO LLVM Toolchain
# See https://llvm.org/docs/HowToBuildWithPGO.html#building-clang-with-pgo
dnf copr enable -y @fedora-llvm-team/llvm-pgo-optimized fedora-rawhide-x86_64
dnf remove -y clang clang-libs clang-resource-filesystem llvm llvm-libs
dnf install --enablerepo='copr:copr.fedorainfracloud.org:group_fedora-llvm-team:llvm-pgo-optimized' -y clang clang-libs clang-resource-filesystem llvm llvm-libs

configure_build_run pgo

# Compare the results...

bash