#!/usr/bin/bash

set -x

function configure_build_run {
    cp ~/sqlite-amalgamation-3420000.zip .
    unzip sqlite-amalgamation-3420000.zip
    cd sqlite-amalgamation-3420000
    multitime -n 10 clang -o sqlite3.o -c sqlite3.c
}

cd ~
wget https://www.sqlite.org/2023/sqlite-amalgamation-3420000.zip

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

mkdir -pv ~/rawhide
cd ~/rawhide

configure_build_run

# Install and enable the repository that provides the PGO LLVM Toolchain
# See https://llvm.org/docs/HowToBuildWithPGO.html#building-clang-with-pgo
dnf copr enable -y @fedora-llvm-team/llvm-pgo-optimized fedora-rawhide-x86_64
dnf remove -y clang clang-libs clang-resource-filesystem llvm llvm-libs
dnf install --enablerepo='copr:copr.fedorainfracloud.org:group_fedora-llvm-team:llvm-pgo-optimized' -y clang clang-libs clang-resource-filesystem llvm llvm-libs

mkdir -pv ~/pgo
cd ~/pgo

configure_build_run

# Compare the results...

bash
