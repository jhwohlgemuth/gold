.PHONY: check lint format
format:
	@for script in $(SCRIPTS) ; do \
        dos2unix $$script; \
    done
	@for file in $(FILES) ; do \
        dos2unix $$file; \
    done
	@for fn in $(FUNCTIONS) ; do \
        dos2unix $$fn; \
    done
lint:
	@for image in $(IMAGES) ; do \
        hadolint ./Dockerfile.$$image ; \
    done
	hadolint ./Dockerfile
check:
	@for script in $(SCRIPTS) ; do \
		shfmt --write --list $$script; \
        shellcheck $$script; \
    done
	@for fn in $(FUNCTIONS) ; do \
		shfmt --write --list --indent 4 --case-indent --space-redirects $$fn; \
        shellcheck $$fn; \
    done

.PHONY: build-image
build-image: format
	@docker build --no-cache -t ${REGISTRY}/${GITHUB_ACTOR}/${TASK}:$(VERSION) -f ./Dockerfile.${TASK} .
	@docker build --no-cache -t ${REGISTRY}/${GITHUB_ACTOR}/${TASK} -f ./Dockerfile.${TASK} .

.PHONY: gold gold-push
gold: format
	@docker build --no-cache -t ${REGISTRY}/${GITHUB_ACTOR}/gold -f ./Dockerfile .
gold-push:
	@docker push "${REGISTRY}/${GITHUB_ACTOR}/gold"

.PHONY: dev dev-push
dev:
	@$(MAKE) TASK=$@ --no-print-directory build-image
dev-push:
	@docker push "${REGISTRY}/${GITHUB_ACTOR}/dev:${VERSION}"
	@docker push "${REGISTRY}/${GITHUB_ACTOR}/dev"

.PHONY: notebook notebook-push
notebook:
	@$(MAKE) TASK=$@ --no-print-directory build-image
notebook-push:
	@docker push "${REGISTRY}/${GITHUB_ACTOR}/notebook:${VERSION}"
	@docker push "${REGISTRY}/${GITHUB_ACTOR}/notebook"

.PHONY: rust rust-push
rust:
	@$(MAKE) TASK=$@ --no-print-directory build-image
rust-push:
	@docker push "${REGISTRY}/${GITHUB_ACTOR}/rust:${VERSION}"
	@docker push "${REGISTRY}/${GITHUB_ACTOR}/rust"

.PHONY: web web-push
web:
	@$(MAKE) TASK=$@ --no-print-directory build-image
web-push:
	@docker push "${REGISTRY}/${GITHUB_ACTOR}/web:${VERSION}"
	@docker push "${REGISTRY}/${GITHUB_ACTOR}/web"
#
# Build variables
#
VERSION = `cat VERSION`
REGISTRY = ghcr.io
GITHUB_ACTOR = jhwohlgemuth
IMAGES = \
	dev \
	notebook \
	rust \
	web
SCRIPTS = \
	./provision/scripts/dev/configure_locale.sh \
	./provision/scripts/dev/configure_ohmyzsh.sh \
	./provision/scripts/dev/install_apptainer.sh \
	./provision/scripts/dev/install_dependencies.sh \
	./provision/scripts/dev/install_docker.sh \
	./provision/scripts/dev/install_dotnet.sh \
	./provision/scripts/dev/install_homebrew.sh \
	./provision/scripts/dev/install_nix.sh \
	./provision/scripts/dev/install_ohmyzsh.sh \
	./provision/scripts/gold/install_aeneas.sh \
	./provision/scripts/gold/install_coq.sh \
	./provision/scripts/gold/install_creusot.sh \
	./provision/scripts/gold/install_dependencies.sh \
	./provision/scripts/gold/install_frama-c.sh \
	./provision/scripts/gold/install_klee.sh \
	./provision/scripts/gold/install_ocaml.sh \
	./provision/scripts/gold/install_provers.sh \
	./provision/scripts/gold/install_verus.sh \
	./provision/scripts/notebook/download_notebooks.sh \
	./provision/scripts/notebook/install_code_server.sh \
	./provision/scripts/notebook/install_conda.sh \
	./provision/scripts/notebook/install_dotnet_jupyter_kernel.sh \
	./provision/scripts/notebook/install_elixir_jupyter_kernel.sh \
	./provision/scripts/notebook/install_elixir.sh \
	./provision/scripts/notebook/install_extensions.sh \
	./provision/scripts/notebook/install_nim.sh \
	./provision/scripts/notebook/install_scala_jupyter_kernel.sh \
	./provision/scripts/rust/install_wasm_runtimes.sh
FUNCTIONS = \
	./provision/functions/cleanup \
	./provision/functions/is_command \
	./provision/functions/is_installed \
	./provision/functions/move_lines \
	./provision/functions/remove_empty_lines \
	./provision/functions/requires
FILES = \
	./config/code-server/service/finish \
	./config/code-server/service/run \
	./config/jupyter/service/finish \
	./config/jupyter/service/run \
	./config/verdaccio/service/finish \
	./config/verdaccio/service/log \
	./config/verdaccio/service/run \
	./config/.utoprc \
	./config/init.ml
