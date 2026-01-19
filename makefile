# Image Values
REGISTRY := localhost
IMAGE := stationeers-test
IMAGE_REF := $(REGISTRY)/$(IMAGE)

# Git commit hash
HASH := $(shell git rev-parse --short HEAD)

# Buildah/Podman/Docker Options
CONTAINER_NAME := stationeers-test
VOLUME_NAME := stationeers-data
BUILD_OPTS := -f ./container/Containerfile
RUN_OPTS := --name $(CONTAINER_NAME) -d --mount type=volume,source=$(VOLUME_NAME),target=/home/steam/stationeers -p 27015:27015/udp -p 27016:27016/udp

# Makefile targets
.PHONY: build run cleanup

build:
	docker build $(BUILD_OPTS) -t $(IMAGE_REF):$(HASH) ./container

run:
	docker volume create $(VOLUME_NAME)
	docker run $(RUN_OPTS) $(IMAGE_REF):$(HASH)

cleanup:
	docker rm -f $(CONTAINER_NAME)
	docker rmi -f $(IMAGE_REF):$(HASH)
	docker volume rm $(VOLUME_NAME)
