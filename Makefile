#!make
include .env
-include .env.secret

prepare: convert lint check update-mamba-version
images: images-amd64 images-arm64
images-amd64: prepare terminal-image-amd64 notebook-image-amd64 gold-image-amd64
images-arm64: prepare notebook-image-arm64
images-ornl: prepare
	@for image in $(IMAGES) ; do \
		$(MAKE) --no-print-directory $$image-image-ornl; \
	done
push-all:
	@for image in $(IMAGES) ; do \
		$(MAKE) IMAGE=$$image --no-print-directory push-image; \
	done
push-all-ornl:
	@for image in $(IMAGES) ; do \
		$(MAKE) \
			IMAGE=$$image \
			BUILD_REGISTRY=${REGISTRY_ORNL} \
			BUILD_PROJECT=${HARBOR_PROJECT} \
			--no-print-directory \
			push-image; \
	done
changelog:
	@git-cliff --output CHANGELOG.md --github-token ${GITHUB_TOKEN}
update-mamba-version:
	@echo "Fetching current micromamba version from Homebrew..."
	@bash -euo pipefail -c 'version=$$(curl -fsSL https://formulae.brew.sh/api/formula/micromamba.json | jq -er ".versions.stable + (if .revision > 0 then \"_\" + (.revision | tostring) else \"\" end)"); \
		perl -pi -e "s/^ARG MAMBA_VERSION=.*/ARG MAMBA_VERSION=$$version/" Dockerfile.notebook; \
		echo "Updated MAMBA_VERSION to $$version in Dockerfile.notebook"'
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
#
# Build tasks
#
gold-image-amd64: notebook-image-amd64
	@$(MAKE) IMAGE=gold DOCKERFILE=./Dockerfile BUILD_PLATFORM=linux/amd64 --no-print-directory build-image
terminal-image-amd64:
	@$(MAKE) IMAGE=terminal BUILD_PLATFORM=linux/amd64 --no-print-directory build-image
notebook-image-amd64: terminal-image-amd64
	@$(MAKE) IMAGE=notebook BUILD_PLATFORM=linux/amd64 --no-print-directory build-image
terminal-image-arm64:
	@$(MAKE) IMAGE=terminal BUILD_PLATFORM=linux/arm64 --no-print-directory build-image
notebook-image-arm64: terminal-image-arm64
	@$(MAKE) IMAGE=notebook BUILD_PLATFORM=linux/arm64 --no-print-directory build-image
terminal-image:
	@docker buildx build --platform linux/amd64,linux/arm64 --build-arg VERSION=$(VERSION) --file Dockerfile.terminal --tag ${REGISTRY}/${GITHUB_ACTOR}/terminal:$(VERSION) --push .
notebook-image:
	@docker buildx build --platform linux/amd64,linux/arm64 --build-arg VERSION=$(VERSION) --file Dockerfile.notebook --tag ${REGISTRY}/${GITHUB_ACTOR}/notebook:$(VERSION) --push .
gold-image-ornl:
	@$(MAKE) \
		IMAGE=gold \
		DOCKERFILE=./Dockerfile \
		BUILD_REGISTRY=${REGISTRY_ORNL} \
		BUILD_PROJECT=${HARBOR_PROJECT} \
		--no-print-directory \
		build-image
terminal-image-ornl:
	@$(MAKE) \
		IMAGE=terminal \
		BUILD_REGISTRY=${REGISTRY_ORNL} \
		BUILD_PROJECT=${HARBOR_PROJECT} \
		--no-print-directory \
		build-image
notebook-image-ornl:
	@$(MAKE) \
		IMAGE=notebook \
		BUILD_REGISTRY=${REGISTRY_ORNL} \
		BUILD_PROJECT=${HARBOR_PROJECT} \
		--no-print-directory \
		build-image
#
# Push tasks
#
push-gold:
	@$(MAKE) IMAGE=gold --no-print-directory push-image
push-terminal:
	@$(MAKE) IMAGE=terminal --no-print-directory push-image
push-notebook:
	@$(MAKE) IMAGE=notebook --no-print-directory push-image
push-gold-ornl:
	@$(MAKE) \
		IMAGE=gold \
		BUILD_REGISTRY=${REGISTRY_ORNL} \
		BUILD_PROJECT=${HARBOR_PROJECT} \
		--no-print-directory \
		push-image
push-terminal-ornl:
	@$(MAKE) \
		IMAGE=terminal \
		BUILD_REGISTRY=${REGISTRY_ORNL} \
		BUILD_PROJECT=${HARBOR_PROJECT} \
		--no-print-directory \
		push-image
push-notebook-ornl:
	@$(MAKE) \
		IMAGE=notebook \
		BUILD_REGISTRY=${REGISTRY_ORNL} \
		BUILD_PROJECT=${HARBOR_PROJECT} \
		--no-print-directory \
		push-image
#
# Parameterized tasks
#
DOCKERFILE ?= ./Dockerfile.${IMAGE}
BUILD_REGISTRY ?= ${REGISTRY}
BUILD_PROJECT ?= ${GITHUB_ACTOR}
BUILD_PLATFORM ?= linux/amd64
build-image:
	@docker build \
		--platform ${BUILD_PLATFORM} \
		--no-cache \
		--build-arg VERSION=$(VERSION) \
		--file ${DOCKERFILE} \
		--tag ${BUILD_REGISTRY}/${BUILD_PROJECT}/${IMAGE}:$(VERSION) \
		.
	@docker tag ${BUILD_REGISTRY}/${BUILD_PROJECT}/${IMAGE}:$(VERSION) ${BUILD_REGISTRY}/${BUILD_PROJECT}/${IMAGE}:latest
push-image:
	@docker push "${BUILD_REGISTRY}/${BUILD_PROJECT}/${IMAGE}:${VERSION}"
	@docker push "${BUILD_REGISTRY}/${BUILD_PROJECT}/${IMAGE}"

#
# Build variables
#
IMAGES = \
	terminal \
	notebook \
	gold
FILES = \
	./.shellcheckrc \
	./provision/gold/Brewfile \
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
	./config/verdaccio/service/run \
	./config/mcp-lean/service/finish \
	./config/mcp-lean/service/run
SCRIPTS = \
	./provision/healthcheck \
	./provision/terminal/configure_locale.sh \
	./provision/terminal/configure_ohmyzsh.sh \
	./provision/terminal/create_nonroot_user.sh \
	./provision/terminal/install_dependencies.sh \
	./provision/terminal/install_dotnet.sh \
	./provision/notebook/install_conda.sh \
	./provision/notebook/install_dependencies.sh \
	./provision/gold/install_dependencies.sh
.PHONY: \
	build-image \
	changelog \
	check \
	convert \
	gold-image-amd64 \
	gold-image-ornl \
	images \
	images-amd64 \
	images-arm64 \
	images-ornl \
	lint \
	notebook-image-amd64 \
	notebook-image-arm64 \
	notebook-image \
	notebook-image-ornl \
	prepare \
	push-all \
	push-all-ornl \
	push-gold \
	push-gold-ornl \
	push-image \
	push-notebook \
	push-notebook-ornl \
	push-terminal \
	push-terminal-ornl \
	terminal-image-amd64 \
	terminal-image-arm64 \
	terminal-image \
	terminal-image-ornl \
	update-mamba-version
