#! /bin/bash
set -e

requires \
    ast-grep \
    brew \
    direnv \
    fuck \
    pip3 \
    pwsh \
    python3 \
    zoxide \
    zsh
main() {
    local ZSHRC="${HOME}/.zshrc"
    #
    # Customize .zshrc
    #
    sed -i "s/export TERM=xterm/export TERM=xterm-256color/g" "${ZSHRC}"
    # shellcheck disable=SC2016
    {
        echo 'ZLE_RPROMPT_INDENT=0'
        echo "export SHELL=${SHELL}"
        echo 'export LOCALE_ARCHIVE=/usr/lib/locale/locale-archive'
        echo 'bindkey "\$terminfo[kcuu1]" history-substring-search-up'
        echo 'bindkey "\$terminfo[kcud1]" history-substring-search-down'
        echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"'
        echo 'eval "$(direnv hook zsh)"'
        echo 'eval "$(thefuck --alias oops)"'
        echo 'eval "$(zoxide init zsh)"'
        echo "source ${HOME}/.p10k.zsh"
        echo 'alias python=python3'
        echo 'alias pip=pip3'
        echo 'alias sgrep=ast-grep'
    } >> "${ZSHRC}"
}
main "$@"
