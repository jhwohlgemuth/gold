#!make
.PHONY: $(TARGETS)
include .env
include .env.secret

prepare: convert lint check update-mamba-version
images: prepare
	@for image in $(IMAGES) ; do \
		$(MAKE) --no-print-directory $$image-image; \
	done
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
	@MAMBA_VERSION=$$(curl -s https://formulae.brew.sh/api/formula/micromamba.json | jq -r '.versions.stable') && \
	echo "Updating MAMBA_VERSION to $$MAMBA_VERSION in Dockerfile.notebook" && \
	sed -i "s/ARG MAMBA_VERSION=.*/ARG MAMBA_VERSION=$$MAMBA_VERSION/" Dockerfile.notebook && \
	echo "MAMBA_VERSION updated successfully"
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
gold-image:
	@$(MAKE) IMAGE=gold DOCKERFILE=./Dockerfile --no-print-directory build-image
terminal-image:
	@$(MAKE) IMAGE=terminal --no-print-directory build-image
notebook-image:
	@$(MAKE) IMAGE=notebook --no-print-directory build-image
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
build-image:
	@docker build \
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
	./config/verdaccio/service/run
SCRIPTS = \
	./provision/healthcheck \
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
	images-ornl \
	push-all \
	changelog \
	check \
	convert \
	lint \
	update-mamba-version \
	gold-image \
	terminal-image \
	notebook-image \
	gold-image-ornl \
	terminal-image-ornl \
	notebook-image-ornl \
	push-gold \
	push-terminal \
	push-notebook \
	build-image \
	push-image
