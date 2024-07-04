#! /bin/sh

apt-get update
#
# Install essential dependencies
#
apt-get install --no-install-recommends --yes \
    binfmt-support \
    build-essential \
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
    neovim \
    openssh-server \
    python3-dev \
    python3-venv \
    python3-pip \
    python3-setuptools \
    rlwrap \
    screen \
    software-properties-common \
    stow \
    tree \
    tzdata \
    unzip \
    xvfb \
    zip \
    zsh
