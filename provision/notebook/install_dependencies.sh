#! /bin/sh
set -e

export DEBIAN_FRONTEND=noninteractive
apt-get update
#
# Install LPython dependencies
#
apt-get install --no-install-recommends -y \
    binutils-dev \
    clang \
    zlib1g-dev
