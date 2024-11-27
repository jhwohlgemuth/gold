{ pkgs ? import <nixpkgs> {} }:
with pkgs; [
    asdf-vm
    ast-grep
    bat
    btop
    direnv
    du-dust
    grex
    gum
    just
    ripgrep
    thefuck
    up
    yq
]