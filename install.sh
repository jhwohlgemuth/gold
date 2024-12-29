#! /bin/bash
set -e

main() {
    curl -fsSL https://shell.jasonwohlgemuth.com/install.sh | bash -s -- gold
}
main "$@"