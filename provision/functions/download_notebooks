#! /bin/bash
# shellcheck disable=SC2155
set -e

requires \
    curl \
    gum
main() {
    local PWD="$(pwd)"
    local EMPTY="[ ] "
    local COLOR="${GOLD_FOREGROUND_COLOR:-220}"
    local NOTEBOOKS_DIR=${1:-'/root/dev/notebooks'}
    local TITLE="$(gum style --foreground "${COLOR}" 'Download') notebooks"
    local CHECKMARK="$(gum style --foreground 46 '🗸')"
    gum style \
        --border normal \
        --border-foreground "${COLOR}" \
        --margin "1" \
        --padding "1 2" \
        "${TITLE}"
    DATA="""
        C#:csharp
        Clojure:clojure
        Elixir:elixir
        F#:fsharp
        Go:go
        Haskell:haskell
        JavaScript:javascript
        Julia:julia
        Kotlin:kotlin
        Lua:lua
        PowerShell:powershell
        Python:python
        R_language:R
        Ruby:ruby
        Rust:rust
        Scala:scala
        Swift:swift
    """
    # shellcheck disable=SC2010
    NOTEBOOKS=$(ls "${NOTEBOOKS_DIR}" | grep 'ipynb$' | cut -d'.' -f1)
    EXISTING=$(echo "${DATA}" | grep ":${NOTEBOOKS}$" | cut -d':' -f1)
    for NOTEBOOK in ${EXISTING}; do
        DATA=$(echo "${DATA}" | sed "/${NOTEBOOK}:/d")
    done
    CHOICES=$(echo "${DATA}" | cut -d':' -f1)
    if [[ $(echo "${DATA}" | tr -d '[:space:]') = '' ]]; then
        echo "> All notebooks already downloaded to \`${NOTEBOOKS_DIR}\`" | gum format
        echo ''
    fi
    # shellcheck disable=SC2046,SC2068,SC2116
    CHOSEN=$(gum choose \
        --no-limit \
        --cursor-prefix="${EMPTY}" \
        --header="Please select notebook(s)" \
        --selected.foreground="${COLOR}" \
        --selected-prefix="[X] " \
        --unselected-prefix="${EMPTY}" \
        $(echo "${CHOICES}"))
    LANGUAGES=$(echo "${DATA}" | grep "${CHOSEN}:" | cut -d':' -f2)
    mkdir -p "${NOTEBOOKS_DIR}"
    cd "${NOTEBOOKS_DIR}" || exit
    for LANGUAGE in ${LANGUAGES}; do
        URL="https://raw.githubusercontent.com/jhwohlgemuth/language-comparison/main/${LANGUAGE}.ipynb"
        curl --create-dirs --silent -O "${URL}"
        echo "    ${CHECKMARK} Downloaded $(gum style --foreground 46 "${LANGUAGE}") notebook"
    done
    cd "${PWD}" || exit
    echo ''
    echo "> Notebooks downloaded to \`${NOTEBOOKS_DIR}\`" | gum format
    echo ''
}
main "$@"
