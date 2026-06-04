#!make
.PHONY: $(TARGETS)
include .env
include .env.secret

prepare: convert lint check
images: prepare terminal-image notebook-image agentic-image gold-image
push-all: push-terminal push-notebook push-agentic push-gold
changelog:
	@git-cliff --output CHANGELOG.md --github-token ${GITHUB_TOKEN}
check:
	@for script in $(SCRIPTS) ; do \
		shfmt --write --list $$script; \
		shellcheck $$script; \
    done
	@checkov
convert:
	@for script in $(SCRIPTS) ; do \
        dos2unix $$script; \
    done
	@for file in $(FILES) ; do \
        dos2unix $$file; \
    done
lint:
	@for image in $(IMAGES) ; do \
		if [ "$$image" = "gold" ]; then \
			hadolint ./Dockerfile ; \
		else \
			hadolint ./Dockerfile.$$image ; \
		fi; \
    done
# 	@yamllint .
#
# Build tasks
#
gold-image:
	@$(MAKE) IMAGE=gold DOCKERFILE=./Dockerfile --no-print-directory build-image
terminal-image:
	@$(MAKE) IMAGE=terminal --no-print-directory build-image
notebook-image:
	@$(MAKE) IMAGE=notebook --no-print-directory build-image
agentic-image:
	@$(MAKE) IMAGE=agentic --no-print-directory build-image
#
# Push tasks
#
push-gold:
	@$(MAKE) IMAGE=gold --no-print-directory push-image
push-terminal:
	@$(MAKE) IMAGE=terminal --no-print-directory push-image
push-notebook:
	@$(MAKE) IMAGE=notebook --no-print-directory push-image
push-agentic:
	@$(MAKE) IMAGE=agentic --no-print-directory push-image
#
# Parameterized tasks
#
DOCKERFILE ?= ./Dockerfile.${IMAGE}
build-image:
	@docker build \
		--no-cache \
		--build-arg VERSION=$(VERSION) \
		--file ${DOCKERFILE} \
		--secret id=HF_API_TOKEN \
		--tag ${REGISTRY}/${GITHUB_ACTOR}/${IMAGE}:$(VERSION) \
		.
	@docker tag ${REGISTRY}/${GITHUB_ACTOR}/${IMAGE}:$(VERSION) ${REGISTRY}/${GITHUB_ACTOR}/${IMAGE}:latest
push-image:
	@docker push "${REGISTRY}/${GITHUB_ACTOR}/${IMAGE}:${VERSION}"
	@docker push "${REGISTRY}/${GITHUB_ACTOR}/${IMAGE}"
#
# Build variables
#
IMAGES = \
	terminal \
	notebook \
	agentic \
	gold
FILES = \
	./.shellcheckrc \
	./provision/gold/Brewfile \
	./provision/terminal/Brewfile \
	./config/code-server/service/finish \
	./config/code-server/service/run \
	./config/jupyter/service/finish \
	./config/jupyter/service/run \
	./config/llama.cpp/service/finish \
	./config/llama.cpp/service/log \
	./config/llama.cpp/service/run \
	./config/marimo/service/finish \
	./config/marimo/service/log \
	./config/marimo/service/run \
	./config/verdaccio/service/finish \
	./config/verdaccio/service/log \
	./config/verdaccio/service/run
SCRIPTS = \
	./provision/healthcheck \
	./provision/agentic/build_llama_cpp_from_source.sh \
	./provision/terminal/configure_locale.sh \
	./provision/terminal/configure_ohmyzsh.sh \
	./provision/terminal/create_nonroot_user.sh \
	./provision/terminal/install_dependencies.sh \
	./provision/terminal/install_dotnet.sh \
	./provision/notebook/install_dependencies.sh \
	./provision/gold/install_dependencies.sh
TARGETS = \
	prepare \
	images \
	push-all \
	changelog \
	check \
	convert \
	lint \
	gold-image \
	terminal-image \
	notebook-image \
	push-gold \
	push-terminal \
	push-notebook \
	build-image \
	push-image
