# Ultramarine OS Pipa image builder
#
# Usage:
#   make builder          Build the Docker builder image
#   make image            Build the GNOME disk image
#   make clean            Remove generated images

SHELL := /bin/bash
BUILDER_IMAGE := ultramarine-pipa-builder
OUTPUT_DIR := output

BUILD_GIT_REV ?= $(shell git rev-parse --short HEAD 2>/dev/null || echo unknown)
PIPA_PKGS_BRANCH ?= main

DOCKER_RUN := docker run --rm --privileged \
	-v "$(CURDIR)/$(OUTPUT_DIR):/build/output" \
	-v /dev:/dev \
	-e BUILD_GIT_REV="$(BUILD_GIT_REV)" \
	-e PIPA_PKGS_BRANCH="$(PIPA_PKGS_BRANCH)" \
	$(BUILDER_IMAGE)

.PHONY: help builder image clean check-docker

help:
	@echo "Ultramarine OS Pipa image builder"
	@echo
	@echo "Targets:"
	@echo "  builder   Build the Docker builder image"
	@echo "  image     Build the GNOME disk image"
	@echo "  clean     Remove generated images"
	@echo
	@echo "Environment variables:"
	@echo "  PIPA_PKGS_BRANCH   Branch of pipa-pkgs to clone (default: main)"
	@echo "  BUILD_GIT_REV      Git revision stamped into build metadata"

check-docker:
	@command -v docker >/dev/null || { echo "docker is required but not installed."; exit 1; }

builder: check-docker
	docker build -t $(BUILDER_IMAGE) .

$(OUTPUT_DIR):
	mkdir -p $(OUTPUT_DIR)

image: builder $(OUTPUT_DIR)
	$(DOCKER_RUN)

clean:
	rm -rf $(OUTPUT_DIR)/*
