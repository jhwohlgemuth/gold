#! /bin/bash
set -e

requires \
    cmake \
    git \
    nvcc
main() {
    local -a CMAKE_ARGS_ARRAY=()
    local NVCC_BIN
    local SRC_DIRECTORY="${HOME}/llamacpp"
    NVCC_BIN="$(command -v nvcc)"
    if [[ -n "${CMAKE_ARGS:-}" ]]; then
        # Split optional CMAKE_ARGS into an array so arguments are passed safely.
        read -r -a CMAKE_ARGS_ARRAY <<< "${CMAKE_ARGS}"
    fi
    git clone https://github.com/ggml-org/llama.cpp.git "${SRC_DIRECTORY}"
    pushd "${SRC_DIRECTORY}" > /dev/null || exit
    cmake -B build \
        -DGGML_NATIVE=OFF \
        -DGGML_CUDA=ON \
        -DGGML_BACKEND_DL=ON \
        -DGGML_CPU_ALL_VARIANTS=ON \
        -DLLAMA_BUILD_TESTS=OFF \
        -DCMAKE_CUDA_COMPILER="${NVCC_BIN}" \
        "${CMAKE_ARGS_ARRAY[@]}" \
        -DCMAKE_EXE_LINKER_FLAGS=-Wl,--allow-shlib-undefined \
        .
    cmake --build build --config Release -j"$(nproc)"
    popd > /dev/null || exit
    mv "${SRC_DIRECTORY}/build/bin/llama-cli" /usr/local/bin/llama-cli
    mv "${SRC_DIRECTORY}/build/bin/llama-server" /usr/local/bin/llama-server
    rm -rf "${SRC_DIRECTORY}"
}
main "$@"
