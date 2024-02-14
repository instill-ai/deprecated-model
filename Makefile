.DEFAULT_GOAL:=help

#============================================================================

# load environment variables
include .env
export

# NVIDIA_GPU_AVAILABLE:
# 	The env variable NVIDIA_GPU_AVAILABLE is set to true if NVIDIA GPU is available. Otherwise, it will be set to false.
# RAY_PLATFORM:
# 	By default, the env variable RAY_PLATFORM is set to cpu, if NVIDIA GPU is available, it will be set to gpu.
# 	Specify the env variable RAY_PLATFORM to override the default value.
# NVIDIA_VISIBLE_DEVICES:
# 	By default, the env variable NVIDIA_VISIBLE_DEVICES is set to all if NVIDIA GPU is available. Otherwise, it is unset.
#	Specify the env variable NVIDIA_VISIBLE_DEVICES to override the default value.
RAY_PLATFORM := ${RAY_PLATFORM}
NVIDIA_VISIBLE_DEVICES := ${NVIDIA_VISIBLE_DEVICES}
ifeq ($(shell nvidia-smi 2>/dev/null 1>&2; echo $$?),0)
	NVIDIA_GPU_AVAILABLE := true
	ifndef RAY_PLATFORM
		RAY_PLATFORM := gpu
	endif
	ifndef NVIDIA_VISIBLE_DEVICES
		NVIDIA_VISIBLE_DEVICES := all
	endif
else
	NVIDIA_GPU_AVAILABLE := false
	RAY_PLATFORM := cpu
endif

UNAME_S := $(shell uname -s)

ifeq ($(shell uname -p),arm)
	RAY_PLATFORM := arm
else ifeq ($(shell uname -m),aarch64)
	RAY_PLATFORM := arm
else ifeq ($(shell uname -m),arm64)
	RAY_PLATFORM := arm
else ifeq ($(shell uname -s),Darwin)
	RAY_PLATFORM := arm
endif

INSTILL_MODEL_VERSION := $(shell git tag --sort=committerdate | grep -E '[0-9]' | tail -1 | cut -b 2-)

CONTAINER_BUILD_NAME := model-build
CONTAINER_COMPOSE_NAME := model-dind
CONTAINER_COMPOSE_IMAGE_NAME := instill/model-compose
CONTAINER_BACKEND_INTEGRATION_TEST_NAME := model-backend-integration-test

HELM_NAMESPACE := instill-ai
HELM_RELEASE_NAME := model

#============================================================================

.PHONY: all
all:			## Launch all services with their up-to-date release version
	@if [ "${BUILD}" = "true" ]; then make build-release; fi
	@if [ ! "$$(docker image inspect ${CONTAINER_COMPOSE_IMAGE_NAME}:${INSTILL_MODEL_VERSION} --format='yes' 2> /dev/null)" = "yes" ]; then \
		docker build --progress plain \
			--build-arg INSTILL_CORE_VERSION=${INSTILL_CORE_VERSION} \
			--build-arg ALPINE_VERSION=${ALPINE_VERSION} \
			--build-arg GOLANG_VERSION=${GOLANG_VERSION} \
			--build-arg K6_VERSION=${K6_VERSION} \
			--build-arg CACHE_DATE="$(shell date)" \
			--build-arg MODEL_BACKEND_VERSION=${MODEL_BACKEND_VERSION} \
			--build-arg CONTROLLER_MODEL_VERSION=${CONTROLLER_MODEL_VERSION} \
			--target release \
			-t ${CONTAINER_COMPOSE_IMAGE_NAME}:${INSTILL_MODEL_VERSION} .; \
	fi
	@if ! docker compose ls -q | grep -q "instill-core"; then \
		export TMP_CONFIG_DIR=$(shell mktemp -d) && \
		export SYSTEM_CONFIG_PATH=$(shell eval echo ${SYSTEM_CONFIG_PATH}) && \
		docker run --rm \
			-v /var/run/docker.sock:/var/run/docker.sock \
			-v $${TMP_CONFIG_DIR}:$${TMP_CONFIG_DIR} \
			-v $${SYSTEM_CONFIG_PATH}:$${SYSTEM_CONFIG_PATH} \
			--name ${CONTAINER_COMPOSE_NAME}-release \
			${CONTAINER_COMPOSE_IMAGE_NAME}:${INSTILL_MODEL_VERSION} /bin/sh -c " \
				cp /instill-ai/core/.env $${TMP_CONFIG_DIR}/.env && \
				cp /instill-ai/core/docker-compose.build.yml $${TMP_CONFIG_DIR}/docker-compose.build.yml && \
				cp -r /instill-ai/core/configs/influxdb $${TMP_CONFIG_DIR} && \
				/bin/sh -c 'cd /instill-ai/core && make all BUILD=${BUILD} PROJECT=core EDITION=$${EDITION:=local-ce} INSTILL_CORE_HOST=$${INSTILL_CORE_HOST} SYSTEM_CONFIG_PATH=$${SYSTEM_CONFIG_PATH} BUILD_CONFIG_DIR_PATH=$${TMP_CONFIG_DIR} OBSERVE_CONFIG_DIR_PATH=$${TMP_CONFIG_DIR}' && \
				rm -rf $${TMP_CONFIG_DIR}/* \
			" && rm -rf $${TMP_CONFIG_DIR}; \
	fi
ifeq (${NVIDIA_GPU_AVAILABLE}, true)
	@docker inspect --type=image instill/ray:${RAY_SERVER_VERSION} >/dev/null 2>&1 || printf "\033[1;33mINFO:\033[0m This may take a while due to the enormous size of the Ray server image, but the image pulling process should be just a one-time effort.\n" && sleep 5
	@cat docker-compose.nvidia.yml | yq '.services.ray_server.deploy.resources.reservations.devices[0].device_ids |= (strenv(NVIDIA_VISIBLE_DEVICES) | split(",")) | ..style="double"' | \
		EDITION=$${EDITION:=local-ce} docker compose -f docker-compose.yml -f - up -d --quiet-pull
else
	@EDITION=$${EDITION:=local-ce} docker compose -f docker-compose.yml up -d --quiet-pull
endif

.PHONY: latest
latest:			## Lunch all dependent services with their latest codebase
	@make build-latest PROFILE=${PROFILE}
	@if ! docker compose ls -q | grep -q "instill-core"; then \
		export TMP_CONFIG_DIR=$(shell mktemp -d) && \
		export SYSTEM_CONFIG_PATH=$(shell eval echo ${SYSTEM_CONFIG_PATH}) && \
		docker run --rm \
			-v /var/run/docker.sock:/var/run/docker.sock \
			-v $${TMP_CONFIG_DIR}:$${TMP_CONFIG_DIR} \
			-v $${SYSTEM_CONFIG_PATH}:$${SYSTEM_CONFIG_PATH} \
			--name ${CONTAINER_COMPOSE_NAME}-latest \
			${CONTAINER_COMPOSE_IMAGE_NAME}:latest /bin/sh -c " \
				cp /instill-ai/core/.env $${TMP_CONFIG_DIR}/.env && \
				cp /instill-ai/core/docker-compose.build.yml $${TMP_CONFIG_DIR}/docker-compose.build.yml && \
				cp -r /instill-ai/core/configs/influxdb $${TMP_CONFIG_DIR} && \
				/bin/sh -c 'cd /instill-ai/core && make latest PROFILE=${PROFILE} PROJECT=core EDITION=$${EDITION:=local-ce:latest} INSTILL_CORE_HOST=$${INSTILL_CORE_HOST} SYSTEM_CONFIG_PATH=$${SYSTEM_CONFIG_PATH} BUILD_CONFIG_DIR_PATH=$${TMP_CONFIG_DIR} OBSERVE_CONFIG_DIR_PATH=$${TMP_CONFIG_DIR}' && \
				rm -rf $${TMP_CONFIG_DIR}/* \
			" && rm -rf $${TMP_CONFIG_DIR}; \
	fi
ifeq (${NVIDIA_GPU_AVAILABLE}, true)
	@docker inspect --type=image instill/ray:${RAY_SERVER_VERSION} >/dev/null 2>&1 || printf "\033[1;33mINFO:\033[0m This may take a while due to the enormous size of the Ray server image, but the image pulling process should be just a one-time effort.\n" && sleep 5
	@cat docker-compose.nvidia.yml | yq '.services.ray_server.deploy.resources.reservations.devices[0].device_ids |= (strenv(NVIDIA_VISIBLE_DEVICES) | split(",")) | ..style="double"' | \
		COMPOSE_PROFILES=${PROFILE} EDITION=$${EDITION:=local-ce:latest} docker compose -f docker-compose.yml -f docker-compose.latest.yml -f - up -d --quiet-pull
else
	@COMPOSE_PROFILES=${PROFILE} EDITION=$${EDITION:=local-ce:latest} docker compose -f docker-compose.yml -f docker-compose.latest.yml up -d --quiet-pull
endif

.PHONY: logs
logs:			## Tail all logs with -n 10
	@EDITION= docker compose logs --follow --tail=10

.PHONY: pull
pull:			## Pull all service images
	@docker inspect --type=image instill/ray:${RAY_SERVER_VERSION} >/dev/null 2>&1 || printf "\033[1;33mINFO:\033[0m This may take a while due to the enormous size of the Ray server image, but the image pulling process should be just a one-time effort.\n" && sleep 5
	@EDITION= docker compose pull

.PHONY: stop
stop:			## Stop all components
	@EDITION= docker compose stop
	@docker run --rm \
		-v /var/run/docker.sock:/var/run/docker.sock \
		--name ${CONTAINER_COMPOSE_NAME}-latest \
		${CONTAINER_COMPOSE_IMAGE_NAME}:latest /bin/sh -c " \
			/bin/sh -c 'cd /instill-ai/core && make stop' \
		"

.PHONY: start
start:			## Start all stopped components
	@docker run --rm \
		-v /var/run/docker.sock:/var/run/docker.sock \
		--name ${CONTAINER_COMPOSE_NAME}-latest \
		${CONTAINER_COMPOSE_IMAGE_NAME}:latest /bin/sh -c " \
			/bin/sh -c 'cd /instill-ai/core && make start' \
		"
	@EDITION= docker compose start

.PHONY: down
down:			## Stop all services and remove all service containers and volumes
	@docker rm -f ${CONTAINER_BUILD_NAME}-latest >/dev/null 2>&1
	@docker rm -f ${CONTAINER_BUILD_NAME}-release >/dev/null 2>&1
	@docker rm -f ${CONTAINER_BACKEND_INTEGRATION_TEST_NAME}-latest >/dev/null 2>&1
	@docker rm -f ${CONTAINER_BACKEND_INTEGRATION_TEST_NAME}-release >/dev/null 2>&1
	@docker rm -f ${CONTAINER_BACKEND_INTEGRATION_TEST_NAME}-helm-latest >/dev/null 2>&1
	@docker rm -f ${CONTAINER_BACKEND_INTEGRATION_TEST_NAME}-helm-release >/dev/null 2>&1
	@docker rm -f ${CONTAINER_COMPOSE_NAME}-latest >/dev/null 2>&1
	@docker rm -f ${CONTAINER_COMPOSE_NAME}-release >/dev/null 2>&1
	@EDITION= docker compose down -v
	@if [ "$$(docker image inspect ${CONTAINER_COMPOSE_IMAGE_NAME}:latest --format='yes' 2> /dev/null)" = "yes" ]; then \
		docker run --rm \
			-v /var/run/docker.sock:/var/run/docker.sock \
			--name ${CONTAINER_COMPOSE_NAME} \
			${CONTAINER_COMPOSE_IMAGE_NAME}:latest /bin/sh -c " \
				if [ \"$$( docker container inspect -f '{{.State.Status}}' core-dind 2>/dev/null)\" != \"running\" ]; then \
					/bin/sh -c 'cd /instill-ai/core && make down'; \
				fi \
			"; \
	elif [ "$$(docker image inspect ${CONTAINER_COMPOSE_IMAGE_NAME}:${INSTILL_MODEL_VERSION} --format='yes' 2> /dev/null)" = "yes" ]; then \
		docker run --rm \
			-v /var/run/docker.sock:/var/run/docker.sock \
			--name ${CONTAINER_COMPOSE_NAME} \
			${CONTAINER_COMPOSE_IMAGE_NAME}:${INSTILL_MODEL_VERSION} /bin/sh -c " \
				if [ \"$$( docker container inspect -f '{{.State.Status}}' core-dind 2>/dev/null)\" != \"running\" ]; then \
					/bin/sh -c 'cd /instill-ai/core && make down'; \
				fi \
			"; \
	fi

.PHONY: images
images:			## List all container images
	@docker compose images

.PHONY: ps
ps:				## List all service containers
	@EDITION= docker compose ps

.PHONY: top
top:			## Display all running service processes
	@EDITION= docker compose top

.PHONY: build-latest
build-latest:				## Build latest images for all model components
	@docker build --progress plain \
		--build-arg ALPINE_VERSION=${ALPINE_VERSION} \
		--build-arg GOLANG_VERSION=${GOLANG_VERSION} \
		--build-arg K6_VERSION=${K6_VERSION} \
		--build-arg CACHE_DATE="$(shell date)" \
		--target latest \
		-t ${CONTAINER_COMPOSE_IMAGE_NAME}:latest .
	@docker run --rm \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-v ${BUILD_CONFIG_DIR_PATH}/.env:/instill-ai/model/.env \
		-v ${BUILD_CONFIG_DIR_PATH}/docker-compose.build.yml:/instill-ai/model/docker-compose.build.yml \
		--name ${CONTAINER_BUILD_NAME}-latest \
		${CONTAINER_COMPOSE_IMAGE_NAME}:latest /bin/sh -c " \
			MODEL_BACKEND_VERSION=latest \
			CONTROLLER_MODEL_VERSION=latest \
			COMPOSE_PROFILES=${PROFILE} docker compose -f docker-compose.build.yml build --progress plain \
		"

.PHONY: build-release
build-release:				## Build release images for all model components
	@docker build --progress plain \
		--build-arg INSTILL_CORE_VERSION=${INSTILL_CORE_VERSION} \
		--build-arg ALPINE_VERSION=${ALPINE_VERSION} \
		--build-arg GOLANG_VERSION=${GOLANG_VERSION} \
		--build-arg K6_VERSION=${K6_VERSION} \
		--build-arg CACHE_DATE="$(shell date)" \
		--build-arg MODEL_BACKEND_VERSION=${MODEL_BACKEND_VERSION} \
		--build-arg CONTROLLER_MODEL_VERSION=${CONTROLLER_MODEL_VERSION} \
		--target release \
		-t ${CONTAINER_COMPOSE_IMAGE_NAME}:${INSTILL_MODEL_VERSION} .
	@docker run --rm \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-v ${BUILD_CONFIG_DIR_PATH}/.env:/instill-ai/model/.env \
		-v ${BUILD_CONFIG_DIR_PATH}/docker-compose.build.yml:/instill-ai/model/docker-compose.build.yml \
		--name ${CONTAINER_BUILD_NAME}-release \
		${CONTAINER_COMPOSE_IMAGE_NAME}:${INSTILL_MODEL_VERSION} /bin/sh -c " \
			MODEL_BACKEND_VERSION=${MODEL_BACKEND_VERSION} \
			CONTROLLER_MODEL_VERSION=${CONTROLLER_MODEL_VERSION} \
			COMPOSE_PROFILES=${PROFILE} docker compose -f docker-compose.build.yml build --progress plain \
		"

.PHONY: integration-test-latest
integration-test-latest:			## Run integration test on the latest model
	@make latest EDITION=local-ce:test ITMODE_ENABLED=true
	@docker run --rm \
		--network instill-network \
		--name ${CONTAINER_BACKEND_INTEGRATION_TEST_NAME}-latest \
		${CONTAINER_COMPOSE_IMAGE_NAME}:latest /bin/sh -c " \
			/bin/sh -c 'cd model-backend && make integration-test API_GATEWAY_URL=${API_GATEWAY_HOST}:${API_GATEWAY_PORT}' && \
			/bin/sh -c 'cd controller-model && make integration-test API_GATEWAY_URL=${API_GATEWAY_HOST}:${API_GATEWAY_PORT}' \
		"
	@make down

.PHONY: integration-test-release
integration-test-release:			## Run integration test on the release model
	@make all BUILD=true EDITION=local-ce:test ITMODE_ENABLED=true
	@docker run --rm \
		--network instill-network \
		--name ${CONTAINER_BACKEND_INTEGRATION_TEST_NAME}-release \
		${CONTAINER_COMPOSE_IMAGE_NAME}:${INSTILL_MODEL_VERSION} /bin/sh -c " \
			/bin/sh -c 'cd model-backend && make integration-test API_GATEWAY_URL=${API_GATEWAY_HOST}:${API_GATEWAY_PORT}' && \
			/bin/sh -c 'cd controller-model && make integration-test API_GATEWAY_URL=${API_GATEWAY_HOST}:${API_GATEWAY_PORT}' \
		"
	@make down

.PHONY: helm-integration-test-latest
helm-integration-test-latest:                       ## Run integration test on the Helm latest for model
	@make build-latest
	@export TMP_CONFIG_DIR=$(shell mktemp -d) && docker run --rm \
		-v ${HOME}/.kube/config:/root/.kube/config \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-v $${TMP_CONFIG_DIR}:$${TMP_CONFIG_DIR} \
		${DOCKER_HELM_IT_EXTRA_PARAMS} \
		--name ${CONTAINER_BACKEND_INTEGRATION_TEST_NAME}-latest \
		${CONTAINER_COMPOSE_IMAGE_NAME}:latest /bin/sh -c " \
			cp /instill-ai/core/.env $${TMP_CONFIG_DIR}/.env && \
			cp /instill-ai/core/docker-compose.build.yml $${TMP_CONFIG_DIR}/docker-compose.build.yml && \
			/bin/sh -c 'cd /instill-ai/core && make build-latest BUILD_CONFIG_DIR_PATH=$${TMP_CONFIG_DIR}' && \
			/bin/sh -c 'cd /instill-ai/core && \
				helm install core charts/core \
					--namespace ${HELM_NAMESPACE} --create-namespace \
					--set edition=k8s-ce:test \
					--set apiGateway.image.tag=latest \
					--set mgmtBackend.image.tag=latest \
					--set console.image.tag=latest \
					--set tags.observability=false \
					--set tags.prometheusStack=false' \
			/bin/sh -c 'rm -rf $${TMP_CONFIG_DIR}/*' \
		" && rm -rf $${TMP_CONFIG_DIR}
	@kubectl rollout status deployment core-api-gateway --namespace ${HELM_NAMESPACE} --timeout=360s
	@export API_GATEWAY_POD_NAME=$$(kubectl get pods --namespace ${HELM_NAMESPACE} -l "app.kubernetes.io/component=api-gateway,app.kubernetes.io/instance=core" -o jsonpath="{.items[0].metadata.name}") && \
		kubectl --namespace ${HELM_NAMESPACE} port-forward $${API_GATEWAY_POD_NAME} ${API_GATEWAY_PORT}:${API_GATEWAY_PORT} > /dev/null 2>&1 &
	@while ! nc -vz localhost ${API_GATEWAY_PORT} > /dev/null 2>&1; do sleep 1; done
	@helm install ${HELM_RELEASE_NAME} charts/model --namespace ${HELM_NAMESPACE} --create-namespace \
		--set itMode.enabled=true \
		--set edition=k8s-ce:test \
		--set modelBackend.image.tag=latest \
		--set controllerModel.image.tag=latest \
		--set rayService.image.tag=latest-${RAY_PLATFORM} \
		--set tags.observability=false
	@kubectl rollout status deployment model-model-backend --namespace instill-ai --timeout=360s
	@kubectl rollout status deployment model-controller-model --namespace instill-ai --timeout=360s
	@sleep 10
ifeq ($(UNAME_S),Darwin)
	@docker run --rm --name ${CONTAINER_BACKEND_INTEGRATION_TEST_NAME}-helm-latest ${CONTAINER_COMPOSE_IMAGE_NAME}:latest /bin/sh -c " \
			/bin/sh -c 'cd model-backend && make integration-test API_GATEWAY_URL=host.docker.internal:${API_GATEWAY_PORT}' && \
			/bin/sh -c 'cd controller-model && make integration-test API_GATEWAY_URL=host.docker.internal:${API_GATEWAY_PORT}' \
		"
else ifeq ($(UNAME_S),Linux)
	@docker run --rm --network host --name ${CONTAINER_BACKEND_INTEGRATION_TEST_NAME}-helm-latest ${CONTAINER_COMPOSE_IMAGE_NAME}:latest /bin/sh -c " \
			/bin/sh -c 'cd model-backend && make integration-test API_GATEWAY_URL=localhost:${API_GATEWAY_PORT}' && \
			/bin/sh -c 'cd controller-model && make integration-test API_GATEWAY_URL=localhost:${API_GATEWAY_PORT}' \
		"
endif
	@helm uninstall ${HELM_RELEASE_NAME} --namespace ${HELM_NAMESPACE}
	@docker run --rm \
		-v ${HOME}/.kube/config:/root/.kube/config \
		${DOCKER_HELM_IT_EXTRA_PARAMS} \
		--name ${CONTAINER_BACKEND_INTEGRATION_TEST_NAME}-latest \
		${CONTAINER_COMPOSE_IMAGE_NAME}:latest /bin/sh -c " \
			/bin/sh -c 'cd /instill-ai/core && helm uninstall core --namespace ${HELM_NAMESPACE}' \
		"
	@kubectl delete namespace ${HELM_NAMESPACE}
	@pkill -f "port-forward"
	@make down

.PHONY: helm-integration-test-release
helm-integration-test-release:                       ## Run integration test on the Helm release for model)
	@make build-release
	@docker run --rm \
		-v ${HOME}/.kube/config:/root/.kube/config \
		${DOCKER_HELM_IT_EXTRA_PARAMS} \
		--name ${CONTAINER_BACKEND_INTEGRATION_TEST_NAME}-release \
		${CONTAINER_COMPOSE_IMAGE_NAME}:${INSTILL_MODEL_VERSION} /bin/sh -c " \
			/bin/sh -c 'cd /instill-ai/core && \
				export $(grep -v '^#' .env | xargs) && \
				helm install core charts/core \
					--namespace ${HELM_NAMESPACE} --create-namespace \
					--set edition=k8s-ce:test \
					--set apiGateway.image.tag=${API_GATEWAY_VERSION} \
					--set mgmtBackend.image.tag=${MGMT_BACKEND_VERSION} \
					--set tags.observability=false \
					--set tags.prometheusStack=false' \
		"
	@kubectl rollout status deployment core-api-gateway --namespace ${HELM_NAMESPACE} --timeout=360s
	@export API_GATEWAY_POD_NAME=$$(kubectl get pods --namespace ${HELM_NAMESPACE} -l "app.kubernetes.io/component=api-gateway,app.kubernetes.io/instance=core" -o jsonpath="{.items[0].metadata.name}") && \
		kubectl --namespace ${HELM_NAMESPACE} port-forward $${API_GATEWAY_POD_NAME} ${API_GATEWAY_PORT}:${API_GATEWAY_PORT} > /dev/null 2>&1 &
	@while ! nc -vz localhost ${API_GATEWAY_PORT} > /dev/null 2>&1; do sleep 1; done
	@helm install ${HELM_RELEASE_NAME} charts/model --namespace ${HELM_NAMESPACE} --create-namespace \
		--set itMode.enabled=true \
		--set edition=k8s-ce:test \
		--set modelBackend.image.tag=${MODEL_BACKEND_VERSION} \
		--set controllerModel.image.tag=${CONTROLLER_MODEL_VERSION} \
		--set rayService.image.tag=${RAY_SERVER_VERSION}-${RAY_PLATFORM} \
		--set tags.observability=false
	@kubectl rollout status deployment model-model-backend --namespace instill-ai --timeout=360s
	@kubectl rollout status deployment model-controller-model --namespace instill-ai --timeout=360s
	@sleep 10
ifeq ($(UNAME_S),Darwin)
	@docker run --rm --name ${CONTAINER_BACKEND_INTEGRATION_TEST_NAME}-helm-release ${CONTAINER_COMPOSE_IMAGE_NAME}:${INSTILL_MODEL_VERSION} /bin/sh -c " \
			/bin/sh -c 'cd model-backend && make integration-test API_GATEWAY_URL=host.docker.internal:${API_GATEWAY_PORT}' && \
			/bin/sh -c 'cd controller-model && make integration-test API_GATEWAY_URL=host.docker.internal:${API_GATEWAY_PORT}' \
		"
else ifeq ($(UNAME_S),Linux)
	@docker run --rm --network host --name ${CONTAINER_BACKEND_INTEGRATION_TEST_NAME}-helm-release ${CONTAINER_COMPOSE_IMAGE_NAME}:${INSTILL_MODEL_VERSION} /bin/sh -c " \
			/bin/sh -c 'cd model-backend && make integration-test API_GATEWAY_URL=localhost:${API_GATEWAY_PORT}' && \
			/bin/sh -c 'cd controller-model && make integration-test API_GATEWAY_URL=localhost:${API_GATEWAY_PORT}' \
		"
endif
	@helm uninstall ${HELM_RELEASE_NAME} --namespace ${HELM_NAMESPACE}
	@docker run --rm \
		-v ${HOME}/.kube/config:/root/.kube/config \
		${DOCKER_HELM_IT_EXTRA_PARAMS} \
		--name ${CONTAINER_BACKEND_INTEGRATION_TEST_NAME}-release \
		${CONTAINER_COMPOSE_IMAGE_NAME}:${INSTILL_MODEL_VERSION} /bin/sh -c " \
			/bin/sh -c 'cd /instill-ai/core && helm uninstall core --namespace ${HELM_NAMESPACE}' \
		"
	@kubectl delete namespace ${HELM_NAMESPACE}
	@pkill -f "port-forward"
	@make down

.PHONY: help
help:       	## Show this help
	@echo "\nMake Application with Docker Compose"
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m (default: help)\n\nTargets:\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-32s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)
