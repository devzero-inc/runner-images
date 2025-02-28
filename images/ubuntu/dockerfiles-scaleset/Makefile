.DEFAULT_GOAL := help

# Run targets in parallel
MAKEFLAGS += -j 4

ARCH ?= amd64
DZ_TAR := dz.tar.gz

DOCKER_REGISTRY ?= docker.io/devzeroinc
UBUNTU_IMAGE_NAME := gha-scale-set-runner-ubuntu
FEDORA_IMAGE_NAME := gha-scale-set-runner-amazonlinux
BASE_IMAGE ?= devzeroinc/gha-runner-image-ubuntu:22.04-devel
TAG ?= $(shell date -u +"%Y-%m-%d")-$(shell git describe --always --abbrev=6 --dirty --match="")

define build_image
	docker build --platform linux/$(ARCH) \
		--build-arg="CACHEBUST=$(TAG)" \
		--build-arg="ARCH=$(ARCH)" \
		$(if $(2),--build-arg="BASE_IMAGE=$(2)") \
		-f $(3) . \
		-t $(1):$(TAG)
endef

define save_image
	docker save -o ./$(1)_$(TAG)_$(ARCH).tar $(1):$(ARCH)-$(TAG)
endef

define push_image
	docker tag $(1):$(TAG) $(DOCKER_REGISTRY)/$(1):$(2)
	docker push $(DOCKER_REGISTRY)/$(1):$(2)
endef

.PHONY: build-ubuntu build-fedora
build-ubuntu: ## Build the Ubuntu image
	$(call build_image,$(UBUNTU_IMAGE_NAME),$(BASE_IMAGE),Dockerfile)

build-fedora: ## Build the Fedora (Amazon Linux) image
	$(call build_image,$(FEDORA_IMAGE_NAME),,Dockerfile.AL23)

.PHONY: save-ubuntu save-fedora
save-ubuntu: build-ubuntu ## Save the Ubuntu image locally
	$(call save_image,$(UBUNTU_IMAGE_NAME))

save-fedora: build-fedora ## Save the Fedora (Amazon Linux) image locally
	$(call save_image,$(FEDORA_IMAGE_NAME))

.PHONY: push-ubuntu push-fedora latest-ubuntu latest-fedora
push-ubuntu: build-ubuntu ## Push Ubuntu image to registry
	$(call push_image,$(UBUNTU_IMAGE_NAME),$(TAG))

push-fedora: build-fedora ## Push Fedora (Amazon Linux) image to registry
	$(call push_image,$(FEDORA_IMAGE_NAME),$(TAG))

latest-ubuntu: build-ubuntu ## Push Ubuntu image with latest tag
	$(call push_image,$(UBUNTU_IMAGE_NAME),latest)

latest-fedora: build-fedora ## Push Fedora (Amazon Linux) image with latest tag
	$(call push_image,$(FEDORA_IMAGE_NAME),latest)

.PHONY: help
help: ## Show this help message
	@echo "\nSpecify a command. The choices are:\n"
	@grep -hE '^[0-9a-zA-Z_-]+:.*?## .*$$' ${MAKEFILE_LIST} | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[0;36m%-20s\033[m %s\n", $$1, $$2}'
	@echo ""
