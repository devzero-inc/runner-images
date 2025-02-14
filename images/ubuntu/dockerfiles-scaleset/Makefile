.DEFAULT_GOAL := help
# Run targets in parallel
MAKEFLAGS += -j 4
ARCH ?= amd64

DZ_TAR := dz.tar.gz
DZ_DIR := dz

DOCKER_REGISTRY ?= docker.io/devzeroinc
IMAGE_NAME ?= gha-scale-set-runner-ubuntu
BASE_IMAGE ?= devzeroinc/gha-runner-image-ubuntu:22.04-devel
TAG ?= $(shell date -u +"%Y-%m-%d")-$(shell git describe --always --abbrev=6 --dirty --match="")-devel

.PHONY: download-cli
download-cli:
	wget -O $(DZ_TAR) https://get.devzero.io/stable/linux-$(ARCH)/dz.tar.gz
	tar -xzf $(DZ_TAR)
	rm -rf $(DZ_TAR)
	
.PHONY: build-image
build-image: download-cli ## Build the image
	docker build --platform linux/$(ARCH) --build-arg="CACHEBUST=$(TAG)" --build-arg="ARCH=$(ARCH)" --build-arg="BASE_IMAGE=$(BASE_IMAGE)" -t $(IMAGE_NAME):$(TAG) .

.PHONY: save-image
save-image: download-cli
	docker build --platform linux/$(ARCH) --build-arg="ARCH=$(ARCH)" --build-arg="CACHEBUST=$(TAG)" -t $(IMAGE_NAME):$(ARCH)-$(TAG) .
	docker save -o ./$(IMAGE_NAME)_$(TAG)_$(ARCH).tar $(IMAGE_NAME):$(ARCH)-$(TAG)

.PHONY: push
push: build-image ## Push the image to the registry using the TAG
	docker tag $(IMAGE_NAME):$(TAG) $(DOCKER_REGISTRY)/$(IMAGE_NAME):$(TAG)
	docker push $(DOCKER_REGISTRY)/$(IMAGE_NAME):$(TAG)

.PHONY: latest
latest: build-image ## Push the image to the registry using latest tag
	docker tag $(IMAGE_NAME):$(TAG) $(DOCKER_REGISTRY)/$(IMAGE_NAME):latest
	docker push $(DOCKER_REGISTRY)/$(IMAGE_NAME):latest

.PHONY: help
help:  ## Show this help
	@echo "\nSpecify a command. The choices are:\n"
	@grep -hE '^[0-9a-zA-Z_-]+:.*?## .*$$' ${MAKEFILE_LIST} | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[0;36m%-20s\033[m %s\n", $$1, $$2}'
	@echo ""
