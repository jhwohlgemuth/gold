FROM ghcr.io/jhwohlgemuth/rust:latest
#
# %labels
#
LABEL author="Jason Wohlgemuth"
LABEL org.opencontainers.image.source=https://github.com/jhwohlgemuth/gold
LABEL org.opencontainers.image.description="Environment for working on provably correct software"
LABEL org.opencontainers.image.licenses=MIT
#
# %arguments
#
ARG HOME=/root
ARG OCAML_VERSION=4.14.1
ARG COQ_VERSION=8.18.0
ARG JUPYTER_KERNELS=/usr/local/share/jupyter/kernels
#
# %environment
#
EXPOSE 1337
EXPOSE 13337
ENV CODE_SERVER_PORT=1337
ENV JUPYTER_PORT=13337
#
# %setup
#
# Only supported by Apptainer
# Run setup commands outside of the container (on the host system) after the base image bootstrap.
#
# %files
#
COPY --chmod=0755 ./provision/gold/* /tmp/scripts/
COPY ./config/jupyter/logo_coq.png /tmp/
COPY ./config/jupyter/logo_ocaml.png /tmp/
#
# %post
#
SHELL ["/bin/bash", "-c"]
RUN nix-env --install --file /tmp/scripts/manifest.nix
SHELL ["/root/miniconda3/bin/conda", "run", "-n", "base", "/bin/bash", "-c"]
RUN /tmp/scripts/install_dependencies.sh \
    && install_ocaml \
    && install_coq \
    && mv /tmp/logo_coq.png "${JUPYTER_KERNELS}/coq/logo-64x64.png" \
    && mv /tmp/logo_ocaml.png "${JUPYTER_KERNELS}/ocaml/logo-64x64.png" \
    && cleanup
#
# %runscript
#
WORKDIR /root/dev
SHELL ["/bin/bash", "-c"]
HEALTHCHECK --interval=5m --timeout=30s --start-period=10s --retries=3 \
    CMD ["sh", "-c", "curl --fail --insecure https://localhost:${CODE_SERVER_PORT} || exit 1"]
ENTRYPOINT [ "/init" ]
CMD ["/bin/zsh"]