
NAME = minio-toolbox
DOCKER_IMAGE = minio-toolbox
DOCKER_IMAGE_VERSION = 1.0.4

IMAGE_NAME = $(DOCKER_IMAGE):$(DOCKER_IMAGE_VERSION)

REGISTRY_SERVER = docker.io
REGISTRY_LIBRARY = yasuhiroabe

PROD_IMAGE_NAME = $(REGISTRY_SERVER)/$(REGISTRY_LIBRARY)/$(IMAGE_NAME)

.PHONY: all build build-prod tag push run stop check

all:
	@echo "please specify a target: make [build|build-prod|push|run|stop|check]"

build:
	sudo docker build . --tag $(DOCKER_IMAGE)

build-prod:
	sudo docker build . --tag $(IMAGE_NAME) --no-cache

tag:
	sudo docker tag $(IMAGE_NAME) $(PROD_IMAGE_NAME)

push:
	sudo docker push $(PROD_IMAGE_NAME)

run:
	sudo docker run -it --rm -d \
		-v `pwd`/data:/root \
		--name $(NAME) \
                $(DOCKER_IMAGE)

exec:
	sudo docker exec -it $(NAME) sh

stop:
	sudo docker stop $(NAME)

check:
	sudo docker ps -f name=$(NAME)
	@echo
	sudo docker images $(IMAGE_NAME)
	@echo
	sudo docker images $(PROD_IMAGE_NAME)

clean:
	find . -name '*~' -type f -exec rm {} \; -print
