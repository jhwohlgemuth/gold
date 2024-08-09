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
SHELL ["/bin/bash", "-c"]
RUN mkdir -p \
    /tmp/scripts \
    "${HOME}/.config/utop/" \
    "${JUPYTER_KERNELS}/coq" \
    "${JUPYTER_KERNELS}/ocaml"
#
# %files
#
COPY ./config/.iex.exs "${HOME}/"
COPY ./config/.utoprc "${HOME}/"
COPY ./config/init.ml "${HOME}/.config/utop/"
COPY ./config/jupyter/logo_coq.png /tmp/
COPY ./config/jupyter/logo_ocaml.png /tmp/
COPY ./provision/scripts/gold/* /tmp/scripts/
#
# %post
#
SHELL ["/bin/bash", "-c"]
RUN nix-env --install --file /tmp/scripts/manifest.nix
SHELL ["/root/miniconda3/bin/conda", "run", "-n", "base", "/bin/bash", "-c"]
RUN chmod +x /tmp/scripts/* \
    && /tmp/scripts/install_dependencies.sh \
    && /tmp/scripts/install_ocaml.sh \
    && /tmp/scripts/install_coq.sh \
    && mv /tmp/scripts/install_aeneas.sh /usr/local/bin/install_aeneas \
    && mv /tmp/scripts/install_creusot.sh /usr/local/bin/install_creusot \
    && mv /tmp/scripts/install_frama-c.sh /usr/local/bin/install_frama-c \
    && mv /tmp/scripts/install_klee.sh /usr/local/bin/install_klee \
    && mv /tmp/scripts/install_provers.sh /usr/local/bin/install_provers \
    && mv /tmp/scripts/install_verus.sh /usr/local/bin/install_verus \
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