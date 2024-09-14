#! /bin/bash
set -e

requires \
    git \
    cmake \
    make \
    z3
install_llvm() {
    apt-get update
    apt-get install --no-install-recommends -y \
        clang-13 \
        llvm-13 \
        llvm-13-dev \
        llvm-13-tools
    echo 'alias clang=clang-13' >> "${HOME}/.zshrc"
}
main() {
    install_llvm
    #
    # Install KLEE dependencies
    #
    apt-get update
    apt-get install --no-install-recommends -y \
        g++-multilib \
        gcc-multilib \
        libcap-dev \
        libgoogle-perftools-dev \
        libncurses5-dev \
        libsqlite3-dev \
        libtcmalloc-minimal4
    #
    # Install KLEE
    #
    local KLEE_SRC_DIRECTORY="/klee"
    local KLEE_BUILD_DIRECTORY="/klee/build"
    git clone https://github.com/klee/klee.git "${KLEE_SRC_DIRECTORY}"
    mkdir -p "${KLEE_BUILD_DIRECTORY}"
    cd "${KLEE_BUILD_DIRECTORY}" || exit
    cmake -DENABLE_SOLVER_Z3=ON -DENABLE_POSIX_RUNTIME=ON -DENABLE_UNIT_TESTS=OFF -DENABLE_SYSTEM_TESTS=OFF "${KLEE_SRC_DIRECTORY}"
    make
    cleanup
    ln -s "${KLEE_BUILD_DIRECTORY}/bin/klee" /usr/local/bin/klee
    cd "${HOME}" || exit
}
main "$@"
