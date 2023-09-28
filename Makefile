
DOCKER_CMD = sudo docker
DOCKER_BUILDER = mabuilder

NAME = minio-toolbox
DOCKER_IMAGE = minio-toolbox
DOCKER_IMAGE_VERSION = 1.0.6

IMAGE_NAME = $(DOCKER_IMAGE):$(DOCKER_IMAGE_VERSION)

REGISTRY_SERVER = docker.io
REGISTRY_LIBRARY = yasuhiroabe

PROD_IMAGE_NAME = $(REGISTRY_SERVER)/$(REGISTRY_LIBRARY)/$(IMAGE_NAME)


.PHONY: all
all:
	@echo "please specify a target: make [build|build-prod|push|run|stop|check]"

.PHONY: build
build:
	$(DOCKER_CMD) build . --tag $(DOCKER_IMAGE)

.PHONY: build-prod
build-prod:
	$(DOCKER_CMD) build . --tag $(IMAGE_NAME) --no-cache

.PHONY: tag
tag:
	$(DOCKER_CMD) tag $(IMAGE_NAME) $(PROD_IMAGE_NAME)

.PHONY: push
push:
	$(DOCKER_CMD) push $(PROD_IMAGE_NAME)

.PHONY: run
run:
	$(DOCKER_CMD) run -it --rm -d \
		-v `pwd`/data:/root \
		--name $(NAME) \
                $(DOCKER_IMAGE)

.PHONY: exec
exec:
	$(DOCKER_CMD) exec -it $(NAME) sh

.PHONY: stop
stop:
	$(DOCKER_CMD) stop $(NAME)

.PHONY: check
check:
	$(DOCKER_CMD) ps -f name=$(NAME)
	@echo
	$(DOCKER_CMD) images $(IMAGE_NAME)
	@echo
	$(DOCKER_CMD) images $(PROD_IMAGE_NAME)

.PHONY: clean
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
