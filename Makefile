MKFILE_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
PROJECT_DIR := $(dir $(MKFILE_PATH))

# Set additional build args for docker image build using make arguments
IMAGE_NAME := pyconkr_api_v3
ifeq (docker-build,$(firstword $(MAKECMDGOALS)))
  TAG_NAME := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
  $(eval $(TAG_NAME):;@:)
endif
TAG_NAME := $(if $(TAG_NAME),$(TAG_NAME),local)
CONTAINER_NAME = $(IMAGE_NAME)_$(TAG_NAME)_container

ifeq ($(DOCKER_DEBUG),true)
	DOCKER_MID_BUILD_OPTIONS = --progress=plain --no-cache
	DOCKER_END_BUILD_OPTIONS = 2>&1 | tee docker-build.log
else
	DOCKER_MID_BUILD_OPTIONS =
	DOCKER_END_BUILD_OPTIONS =
endif

AWS_LAMBDA_READYZ_PAYLOAD = '{\
  "resource": "/readyz/",\
  "path": "/readyz/",\
  "httpMethod": "GET",\
  "requestContext": {\
    "resourcePath": "/readyz/",\
    "httpMethod": "GET",\
    "path": "/readyz/"\
  },\
  "headers": {"accept": "application/json"},\
  "multiValueHeaders": {"accept": ["application/json"]},\
  "queryStringParameters": null,\
  "multiValueQueryStringParameters": null,\
  "pathParameters": null,\
  "stageVariables": null,\
  "body": null,\
  "isBase64Encoded": false\
}'

# =============================================================================
# Local development commands

# Setup local environments
local-setup:
	@poetry install --no-root --sync

# Run local development server
local-api: local-collectstatic
	@ENV_PATH=.env.local poetry run python manage.py runserver 48000

# Run django collectstatic
local-collectstatic:
	@ENV_PATH=.env.local poetry run python manage.py collectstatic --noinput

# Run django shell
local-shell:
	@ENV_PATH=.env.local poetry run python manage.py shell

# Run django migrations
local-migrate:
	@ENV_PATH=.env.local poetry run python manage.py migrate

# For developers not using Poetry
dep-export:
	@poetry export --output requirements.txt --without-hashes

# Devtools
hooks-install: local-setup
	poetry run pre-commit install

hooks-upgrade:
	poetry run pre-commit autoupdate

hooks-lint:
	poetry run pre-commit run --all-files

lint: hooks-lint  # alias

# =============================================================================
# Docker related commands

# Docker image build
# Usage: make docker-build <tag-name:=local>
# if you want to build with debug mode, set DOCKER_DEBUG=true
# ex) make docker-build or make docker-build some_TAG_NAME DOCKER_DEBUG=true
docker-build:
	@docker build \
		-f ./infra/Dockerfile -t $(IMAGE_NAME):$(TAG_NAME) \
		--build-arg GIT_HASH=$(shell git rev-parse HEAD) \
		--build-arg IMAGE_BUILD_DATETIME=$(shell date +%Y-%m-%d_%H:%M:%S) \
		$(DOCKER_MID_BUILD_OPTIONS) $(PROJECT_DIR) $(DOCKER_END_BUILD_OPTIONS)

docker-run: docker-compose-up
	@(docker stop $(CONTAINER_NAME) || true && docker rm $(CONTAINER_NAME) || true) > /dev/null 2>&1
	@docker run -d --rm \
		-p 48000:8080 \
		--env-file .env.local --env-file .env.docker \
		--name $(CONTAINER_NAME) \
		$(IMAGE_NAME):$(TAG_NAME)

docker-readyz:
	@curl -X POST http://localhost:48000/2015-03-31/functions/function/invocations -d $(AWS_LAMBDA_READYZ_PAYLOAD) | jq '.body | fromjson'

docker-test: docker-build docker-run docker-readyz

docker-stop:
	docker stop $(CONTAINER_NAME) || true

docker-rm: docker-stop
	docker rm $(CONTAINER_NAME) || true

# Docker compose setup
# Below commands are for local development only
docker-compose-up:
	docker-compose --env-file .env.local -f ./infra/docker-compose.dev.yaml up -d

docker-compose-down:
	docker-compose --env-file .env.local -f ./infra/docker-compose.dev.yaml down

docker-compose-rm: docker-compose-down
	docker-compose --env-file .env.local -f ./infra/docker-compose.dev.yaml rm
