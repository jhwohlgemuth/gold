FROM ghcr.io/jhwohlgemuth/rust:latest
#
# %labels
#
LABEL author="Jason Wohlgemuth"
LABEL org.opencontainers.image.source https://github.com/jhwohlgemuth/gold
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
ADD ./config/.iex.exs "${HOME}/"
ADD ./config/.utoprc "${HOME}/"
ADD ./config/init.ml "${HOME}/.config/utop/"
ADD ./config/jupyter/logo_coq.png /tmp/
ADD ./config/jupyter/logo_ocaml.png /tmp/
ADD ./provision/scripts/gold/* /tmp/scripts/
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
    && /tmp/scripts/install_provers.sh \
    && elan default leanprover/lean4:stable \
    && mv /tmp/scripts/install_aeneas.sh /usr/local/bin/install_aeneas \
    && mv /tmp/scripts/install_creusot.sh /usr/local/bin/install_creusot \
    && mv /tmp/scripts/install_frama-c.sh /usr/local/bin/install_frama-c \
    && mv /tmp/scripts/install_klee.sh /usr/local/bin/install_klee \
    && mv /tmp/scripts/install_verus.sh /usr/local/bin/install_verus \
    && mv /tmp/logo_coq.png "${JUPYTER_KERNELS}/coq/logo-64x64.png" \
    && mv /tmp/logo_ocaml.png "${JUPYTER_KERNELS}/ocaml/logo-64x64.png" \
    && cleanup
#
# %runscript
#
WORKDIR /root/dev
ENTRYPOINT [ "/init" ]
CMD ["/bin/zsh"]