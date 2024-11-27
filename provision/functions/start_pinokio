#! /bin/bash
set -e

requires \
    Xvfb
main() {
    export DISPLAY=:100
    export GRADIO_SERVER_NAME="0.0.0.0"
    #
    # Create Xvfb buffer for headless mode
    #
    Xvfb "${DISPLAY}" -ac -screen 0 1920x1080x24 -nolisten tcp +extension GLX +render -noreset &
    #
    # Start Pinokio browser
    #
    /opt/Pinokio/pinokio --no-sandbox
}
main "$@"
