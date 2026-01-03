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
ARG USER_NAME=nonroot
ARG HOME="/home/${USER_NAME}"
ARG LEAN_VERSION=stable
ARG OCAML_VERSION=5.4.0
ARG ROCQ_VERSION=9.0.0
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
ENV CODE_SERVER_PORT=1337
ENV JUPYTER_PORT=13337
ENV PATH="${PATH}:${HOME}/.cargo/bin"
#
# %files
#
COPY --chmod=0755 --chown=${USER_NAME}:${USER_NAME} ./provision/healthcheck.sh /
COPY --chmod=0755 ./provision/gold/* /tmp/scripts/
#
# %post
#
SHELL ["/bin/bash", "-c"]
USER root
RUN /tmp/scripts/install_dependencies.sh
USER "${USER_NAME}"
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
RUN cleanup
#
# %runscript
#
USER "${USER_NAME}"
WORKDIR "${HOME}/dev"
SHELL ["/bin/bash", "-c"]
HEALTHCHECK --interval=5m --timeout=30s --start-period=10s --retries=3 \
    CMD ["/bin/bash", "-c", "/healthcheck.sh"]
ENTRYPOINT [ "/init" ]
CMD ["/bin/zsh"]