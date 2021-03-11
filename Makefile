IMAGENAME=quay.io/nagra/ni_kong-oidc
VERSION=2.3.3-ni.1
IMAGE_VERSION=${IMAGENAME}:${VERSION}
IMAGE_LATEST=${IMAGENAME}:latest

.PHONY: help
help: ## this help message
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

.PHONY: build
build: ## build Docker image
	@docker build -t ${IMAGE_LATEST} .
	@docker tag ${IMAGE_LATEST} ${IMAGE_VERSION}

.PHONY: push all
push: ## push Docker image
	@docker push ${IMAGE_LATEST}
	@docker push ${IMAGE_VERSION}

.PHONY: all
all: build push # Build and push Docker image
