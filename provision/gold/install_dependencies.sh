#! /bin/bash

apt-get update
#
# Install essential dependencies
#
apt-get install --no-install-recommends -y \
    apt-utils \
    autoconf \
    libgmp-dev \
    libzmq5 \
    libzmq3-dev \
    pkg-config
