{ pkgs ? import <nixpkgs> {} }:
with pkgs; [
    bun
    deno
    elmPackages.elm
    htmlq
    nodejs_20
]