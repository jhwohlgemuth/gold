ARG VERSION=latest
FROM ghcr.io/jhwohlgemuth/notebook:$VERSION
#
# %labels
#
LABEL author="Jason Wohlgemuth"
LABEL org.opencontainers.image.source=https://github.com/jhwohlgemuth/gold
LABEL org.opencontainers.image.description="Environment for working on provably correct software with Robust Rust, WASM, and more"
LABEL org.opencontainers.image.licenses=MIT
#
# %arguments
#
ARG IMAGE=gold
ARG USER_NAME=nonroot
ARG HOME="/home/${USER_NAME}"
ARG LEAN_VERSION=stable
ARG LEAN_LSP_MCP_VERSION=0.30.0
ARG OCAML_VERSION=5.4.0
ARG ROCQ_VERSION=9.0.0
ARG UV_VERSION=0.8.22
#
# %environment
#
# code-server
EXPOSE 1337
# Verdaccio
EXPOSE 4873
# Jupyter Lab
EXPOSE 13337
# Marimo
EXPOSE 13338
# Lean LSP MCP
EXPOSE 11005

ENV CODE_SERVER_PORT=1337
ENV JUPYTER_PORT=13337
ENV MCP_LEAN_PORT=11005
ENV MCP_LEAN_HOST=0.0.0.0
ENV LEAN_PROJECT_PATH="${HOME}/dev"
ENV LEAN_LOG_LEVEL=INFO
ENV PATH="${PATH}:${HOME}/.cargo/bin"
ENV UV_TOOL_DIR=/opt/uv-tools
ENV UV_TOOL_BIN_DIR=/usr/local/bin
ENV UV_LINK_MODE=copy
#
# %files
#
COPY --chmod=0755 --chown=${USER_NAME}:${USER_NAME} ./provision/healthcheck /healthcheck
COPY --chmod=0755 ./provision/gold/* /tmp/scripts/
COPY --chmod=0755 ./config/mcp-lean/service/* /etc/services.d/mcp-lean/
#
# %post
#
SHELL ["/bin/bash", "-c"]
USER root
RUN /tmp/scripts/install_dependencies.sh
USER "${USER_NAME}"
RUN eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)" \
    && brew bundle --file /tmp/scripts/Brewfile \
    && brew cleanup --prune=all
RUN curl -sSf https://sh.rustup.rs | bash -s -- -y \
    && . "${HOME}/.cargo/env" \
    && rustup toolchain install nightly \
    && rustup target add x86_64-unknown-linux-musl \
    && cargo install \
        evcxr_repl \
        evcxr_jupyter \
    && evcxr_jupyter --install
RUN nix-env -iA \
        nixpkgs.elan \
        nixpkgs.opam \
    && elan default "leanprover/lean4:${LEAN_VERSION}" \
    && install_rocq
USER root
RUN pip install --no-cache-dir "uv==${UV_VERSION}" \
    && install -d "${UV_TOOL_DIR}" \
    && uv tool install "lean-lsp-mcp==${LEAN_LSP_MCP_VERSION}" \
    && chown -R "${USER_NAME}:${USER_NAME}" "${UV_TOOL_DIR}" \
    && chown -R "${USER_NAME}:${USER_NAME}" /etc/services.d/mcp-lean \
    && chmod -R 0755 /etc/services.d/mcp-lean
USER root
RUN cleanup
#
# %runscript
#
USER "${USER_NAME}"
WORKDIR "${HOME}/dev"
SHELL ["/bin/bash", "-c"]
HEALTHCHECK --interval=5m --timeout=30s --start-period=10s --retries=3 \
    CMD ["/bin/bash", "-c", "/healthcheck"]
ENTRYPOINT [ "/init" ]
CMD ["/bin/zsh"]