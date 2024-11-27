#! /bin/bash

apt-get update
#
# Install essential dependencies
#
apt-get install --no-install-recommends -y \
    libssl-dev \
    pkg-config
