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
