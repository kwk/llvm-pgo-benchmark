FROM fedora:rawhide
LABEL description="Test compilers with llvm-test-suite"

USER root
WORKDIR /root

# Install deps to run test-suite
RUN dnf install -y \
        cmake \
        fedora-packager \
        git \
        python3-pip \
        python3-lit \
        python3-pandas \
        python3-scipy \
        ninja-build \
        which \
        coreutils \
        tcl \
        tcl-devel \
        tcl-tclreadline \
        tcl-tclxml-devel \
        tcl-tclxml \
        tcl-zlib \
        tcl-thread-devel

# Clone test suite (in correct version for installed clang version)
# See https://llvm.org/docs/TestSuiteGuide.html
# RUN export VERSION=`clang --version | grep -ioP 'clang version\s\K[0-9\.]+'` \
#     && git clone --depth=1 --branch llvmorg-${VERSION} https://github.com/llvm/llvm-test-suite.git test-suite
RUN git clone --depth=1 https://github.com/llvm/llvm-test-suite.git test-suite

RUN dnf install -y 'dnf-command(copr)' perf
RUN dnf install -y wget
RUN dnf install -y autoconf
RUN git clone --depth=1 https://github.com/ltratt/multitime.git

RUN wget https://github.com/llvm/llvm-project/releases/download/llvmorg-16.0.6/llvm-project-16.0.6.src.tar.xz \
     && tar xf llvm-project-16.0.6.src.tar.xz \
     && mv llvm-project-16.0.6.src llvm-project

RUN dnf install -y jq

COPY entrypoint.sh /root/entrypoint.sh
COPY entrypoint-amalgamation.sh /root/entrypoint-amalgamation.sh
COPY entrypoint-llvm-test-suite.sh /root/entrypoint-llvm-test-suite.sh
COPY entrypoint-compile-clang-source.sh /root/entrypoint-compile-clang-source.sh
USER root
ENTRYPOINT [ "/root/entrypoint.sh" ]
