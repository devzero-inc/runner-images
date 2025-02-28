.DEFAULT_GOAL := help
# Run targets in parallel
MAKEFLAGS += -j 4
ARCH ?= amd64

DZ_TAR := dz.tar.gz

DOCKER_REGISTRY ?= docker.io/devzeroinc
IMAGE_NAME ?= gha-scale-set-runner-ubuntu
BASE_IMAGE ?= devzeroinc/gha-runner-image-ubuntu:22.04-devel
TAG ?= $(shell date -u +"%Y-%m-%d")-$(shell git describe --always --abbrev=6 --dirty --match="")-devel
	
.PHONY: build-ubuntu-image
build-ubuntu-image: ## Build the Ubuntu image
	docker build --platform linux/$(ARCH) --build-arg="CACHEBUST=$(TAG)" --build-arg="ARCH=$(ARCH)" --build-arg="BASE_IMAGE=$(BASE_IMAGE)" -t $(IMAGE_NAME):$(TAG) .

.PHONY: build-fedora-image
build-fedora-image: ## Build the Fedora image
	$(eval IMAGE_NAME=gha-scale-set-runner-amazonlinux)
	docker build --platform linux/$(ARCH) --build-arg="CACHEBUST=$(TAG)" --build-arg="ARCH=$(ARCH)" -t $(IMAGE_NAME):$(TAG) -f Dockerfile.AL23 .

.PHONY: save-ubuntu-image
save-ubuntu-image: ## Save the Ubuntu image to the local docker daemon
	docker build --platform linux/$(ARCH) --build-arg="ARCH=$(ARCH)" --build-arg="CACHEBUST=$(TAG)" -t $(IMAGE_NAME):$(ARCH)-$(TAG) .
	docker save -o ./$(IMAGE_NAME)_$(TAG)_$(ARCH).tar $(IMAGE_NAME):$(ARCH)-$(TAG)

.PHONY: save-fedora-image
save-fedora-image: ## Save the Fedora image to the local docker daemon
	$(eval IMAGE_NAME=gha-scale-set-runner-amazonlinux)
	docker build --platform linux/$(ARCH) --build-arg="ARCH=$(ARCH)" --build-arg="CACHEBUST=$(TAG)" -t $(IMAGE_NAME):$(ARCH)-$(TAG) -f Dockerfile.AL23 .
	docker save -o ./$(IMAGE_NAME)_$(TAG)_$(ARCH).tar $(IMAGE_NAME):$(ARCH)-$(TAG)

.PHONY: push-ubuntu-image
push-ubuntu-image: build-ubuntu-image ## Push the Ubuntu image to the registry using the TAG
	docker tag $(IMAGE_NAME):$(TAG) $(DOCKER_REGISTRY)/$(IMAGE_NAME):$(TAG)
	docker push $(DOCKER_REGISTRY)/$(IMAGE_NAME):$(TAG)

.PHONY: push-fedora-image
push-fedora-image: build-fedora-image ## Push the Fedora image to the registry using the TAG
	$(eval IMAGE_NAME=gha-scale-set-runner-amazonlinux)
	docker tag $(IMAGE_NAME):$(TAG) $(DOCKER_REGISTRY)/$(IMAGE_NAME):$(TAG)
	docker push $(DOCKER_REGISTRY)/$(IMAGE_NAME):$(TAG)

.PHONY: latest-ubuntu
latest-ubuntu: build-ubuntu-image ## Push the Ubuntu image to the registry using latest tag
	docker tag $(IMAGE_NAME):$(TAG) $(DOCKER_REGISTRY)/$(IMAGE_NAME):latest
	docker push $(DOCKER_REGISTRY)/$(IMAGE_NAME):latest

.PHONY: latest-fedora
latest-fedora: build-fedora-image ## Push the Fedora image to the registry using latest tag
	$(eval IMAGE_NAME=gha-scale-set-runner-amazonlinux)
	docker tag $(IMAGE_NAME):$(TAG) $(DOCKER_REGISTRY)/$(IMAGE_NAME):latest
	docker push $(DOCKER_REGISTRY)/$(IMAGE_NAME):latest

.PHONY: help
help:  ## Show this help
	@echo "\nSpecify a command. The choices are:\n"
	@grep -hE '^[0-9a-zA-Z_-]+:.*?## .*$$' ${MAKEFILE_LIST} | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[0;36m%-20s\033[m %s\n", $$1, $$2}'
	@echo ""
