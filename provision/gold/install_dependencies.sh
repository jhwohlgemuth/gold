#! /bin/bash
set -e

export DEBIAN_FRONTEND=noninteractive
apt-get update
#
# Install essential dependencies
#
apt-get install --no-install-recommends -y \
    apt-utils \
    autoconf \
    bubblewrap \
    libffi-dev \
    libgmp-dev \
    libssl-dev \
    libzmq5 \
    libzmq5-dev \
    musl-tools \
    pkg-config
#
# Install Creusot dependencies
#
apt-get install --no-install-recommends -y \
    libcairo2-dev \
    libglib2.0-dev \
    libgtk-3-dev \
    libgtksourceview-3.0-dev \
    pkg-config
#
# Install Frama-C dependencies
#
apt-get install --no-install-recommends -y \
    graphviz \
    gtksourceview-3.0 \
    libcairo2-dev \
    libgtk2.0-dev \
    libgtk-3-dev \
    libunwind-dev
#
# Install Klee dependencies
#
apt-get install --no-install-recommends -y \
    llvm-16 \
    llvm-16-dev \
    llvm-16-tools \
    g++-multilib \
    gcc-multilib \
    libcap-dev \
    libgoogle-perftools-dev \
    libncurses5-dev \
    libsqlite3-dev \
    libtcmalloc-minimal4
