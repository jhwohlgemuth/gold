#! /bin/sh
set -e

export DEBIAN_FRONTEND=noninteractive
apt-get update
#
# Install essential dependencies
#
apt-get install --no-install-recommends --yes \
    binfmt-support \
    build-essential \
    busybox-syslogd \
    cmake \
    curl \
    dos2unix \
    figlet \
    fuse-overlayfs \
    fzf \
    git \
    jq \
    less \
    locales \
    openssh-server \
    python3-dev \
    python3-venv \
    python3-pip \
    python3-setuptools \
    rlwrap \
    screen \
    software-properties-common \
    stow \
    sudo \
    tree \
    tzdata \
    unzip \
    xvfb \
    zip \
    zsh
