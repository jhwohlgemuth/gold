#! /bin/bash
set -e

requires \
    docker
main() {
    local COUNT="${1:-65536}"
    ulimit -n "${COUNT}"
    service docker start
}
main "$@"
