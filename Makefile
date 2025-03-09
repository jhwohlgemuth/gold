.PHONY: check lint format up down

include .env

repl: up
	@docker exec -it env /bin/zsh

up:
	@docker compose up --detach

down:
	@docker compose down --volumes

format:
	@for script in $(SCRIPTS) ; do \
        dos2unix $$script; \
    done
	@for file in $(FILES) ; do \
        dos2unix $$file; \
    done
lint:
	@for image in $(IMAGES) ; do \
        hadolint ./Dockerfile.$$image ; \
    done
	@hadolint ./Dockerfile
	@yamllint .
	@checkov
check:
	@for script in $(SCRIPTS) ; do \
		shfmt --write --list $$script; \
        shellcheck $$script --enable all; \
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
IMAGES = \
	dev \
	notebook \
	rust \
	web
SCRIPTS = \
	./provision/dev/configure_locale.sh \
	./provision/dev/configure_ohmyzsh.sh \
	./provision/dev/install_dependencies.sh \
	./provision/gold/install_dependencies.sh \
	./provision/notebook/install_dependencies.sh \
	./provision/rust/install_dependencies.sh \
	./.github/actions/build-and-push-image/entrypoint.sh
FILES = \
	./provision/dev/Brewfile \
	./provision/dev/manifest.nix \
	./provision/gold/manifest.nix \
	./provision/web/manifest.nix \
	./config/code-server/service/finish \
	./config/code-server/service/run \
	./config/jupyter/service/finish \
	./config/jupyter/service/run \
	./config/verdaccio/service/finish \
	./config/verdaccio/service/log \
	./config/verdaccio/service/run
