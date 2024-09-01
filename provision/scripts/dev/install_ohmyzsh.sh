#! /bin/bash
set -e

requires \
    curl \
    git \
    zsh
main() {
    #
    # Install oh-my-zsh
    #
    sh -c "$(curl -L https://github.com/deluan/zsh-in-docker/releases/download/v1.2.0/zsh-in-docker.sh)" -- \
        -x \
        -p encode64 \
        -p fzf \
        -p git \
        -p history-substring-search \
        -p wd \
        -p https://github.com/zsh-users/zsh-autosuggestions \
        -p https://github.com/zsh-users/zsh-syntax-highlighting \
        -p https://github.com/conda-incubator/conda-zsh-completion \
        -p https://github.com/jhwohlgemuth/zsh-handy-helpers \
        -p https://github.com/jhwohlgemuth/zsh-pentest
}
main "$@"
