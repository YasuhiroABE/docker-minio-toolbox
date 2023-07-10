
DOCKER_CMD = sudo docker
DOCKER_BUILDER = mabuilder

NAME = minio-toolbox
DOCKER_IMAGE = minio-toolbox
DOCKER_IMAGE_VERSION = 1.0.5

IMAGE_NAME = $(DOCKER_IMAGE):$(DOCKER_IMAGE_VERSION)

REGISTRY_SERVER = docker.io
REGISTRY_LIBRARY = yasuhiroabe

PROD_IMAGE_NAME = $(REGISTRY_SERVER)/$(REGISTRY_LIBRARY)/$(IMAGE_NAME)

.PHONY: all build build-prod tag push run stop check

all:
	@echo "please specify a target: make [build|build-prod|push|run|stop|check]"

build:
	$(DOCKER_CMD) build . --tag $(DOCKER_IMAGE)

build-prod:
	$(DOCKER_CMD) build . --tag $(IMAGE_NAME) --no-cache

tag:
	$(DOCKER_CMD) tag $(IMAGE_NAME) $(PROD_IMAGE_NAME)

push:
	$(DOCKER_CMD) push $(PROD_IMAGE_NAME)

run:
	$(DOCKER_CMD) run -it --rm -d \
		-v `pwd`/data:/root \
		--name $(NAME) \
                $(DOCKER_IMAGE)

exec:
	$(DOCKER_CMD) exec -it $(NAME) sh

stop:
	$(DOCKER_CMD) stop $(NAME)

check:
	$(DOCKER_CMD) ps -f name=$(NAME)
	@echo
	$(DOCKER_CMD) images $(IMAGE_NAME)
	@echo
	$(DOCKER_CMD) images $(PROD_IMAGE_NAME)

clean:
	sudo find . -name '*~' -type f -exec rm {} \; -print

.PHONY: docker-buildx-init
docker-buildx-init:
	$(DOCKER_CMD) buildx create --name $(DOCKER_BUILDER) --use

.PHONY: docker-buildx-setup
docker-buildx-setup:
	$(DOCKER_CMD) buildx use $(DOCKER_BUILDER)
	$(DOCKER_CMD) buildx inspect --bootstrap

.PHONY: docker-buildx-prod
docker-buildx-prod:
	$(DOCKER_CMD) buildx build --platform linux/amd64,linux/arm64 --tag $(PROD_IMAGE_NAME) --no-cache --push .
