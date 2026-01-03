#!make
.PHONY: $(TARGETS)
include .env

prepare: convert lint check

convert:
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

check:
	@for script in $(SCRIPTS) ; do \
		shfmt --write --list $$script; \
		shellcheck $$script; \
    done
	@checkov

changelog:
	@git-cliff --output CHANGELOG.md --github-token ${GITHUB_TOKEN}

build-image:
	@docker build \
		--no-cache \
		--build-arg VERSION=$(VERSION) \
		--file ./Dockerfile.${TASK} \
		--tag ${REGISTRY}/${GITHUB_ACTOR}/${TASK}:$(VERSION) \
		.
	@docker build --no-cache  -t ${REGISTRY}/${GITHUB_ACTOR}/${TASK} -f ./Dockerfile.${TASK} .

terminal:
	@$(MAKE) TASK=$@ --no-print-directory build-image
terminal-push:
	@docker push "${REGISTRY}/${GITHUB_ACTOR}/terminal:${VERSION}"
	@docker push "${REGISTRY}/${GITHUB_ACTOR}/terminal"

notebook:
	@$(MAKE) TASK=$@ --no-print-directory build-image
notebook-push:
	@docker push "${REGISTRY}/${GITHUB_ACTOR}/notebook:${VERSION}"
	@docker push "${REGISTRY}/${GITHUB_ACTOR}/notebook"

gold:
	@docker build \
		--no-cache \
		--build-arg VERSION=$(VERSION) \
		--file ./Dockerfile \
		--tag ${REGISTRY}/${GITHUB_ACTOR}/gold:$(VERSION) \
		.
	@docker build --no-cache -t ${REGISTRY}/${GITHUB_ACTOR}/gold -f ./Dockerfile .
gold-push:
	@docker push "${REGISTRY}/${GITHUB_ACTOR}/gold:${VERSION}"
	@docker push "${REGISTRY}/${GITHUB_ACTOR}/gold"

all: prepare terminal notebook gold
#
# Build variables
#
IMAGES = \
	terminal \
	notebook
FILES = \
	./.shellcheckrc \
	./provision/terminal/Brewfile \
	./config/code-server/service/finish \
	./config/code-server/service/run \
	./config/jupyter/service/finish \
	./config/jupyter/service/run \
	./config/marimo/service/finish \
	./config/marimo/service/log \
	./config/marimo/service/run \
	./config/verdaccio/service/finish \
	./config/verdaccio/service/log \
	./config/verdaccio/service/run
SCRIPTS = \
	./provision/healthcheck.sh \
	./provision/terminal/configure_locale.sh \
	./provision/terminal/configure_ohmyzsh.sh \
	./provision/terminal/create_nonroot_user.sh \
	./provision/terminal/install_dependencies.sh \
	./provision/terminal/install_dotnet.sh \
	./provision/notebook/install_dependencies.sh \
	./provision/gold/install_dependencies.sh \
	./.github/actions/build-and-push-image/entrypoint.sh
TARGETS = \
	all \
	build-image \
	changelog \
	check \
	convert \
	fmt \
	format \
	gold \
	gold-push \
	lint \
	notebook \
	notebook-push \
	terminal \
	terminal-push
