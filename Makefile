.DEFAULT_GOAL:=help

#============================================================================

# load environment variables
include .env
export

# NVIDIA_GPU_AVAILABLE:
# 	The env variable NVIDIA_GPU_AVAILABLE is set to true if NVIDIA GPU is available. Otherwise, it will be set to false.
# TRITON_CONDA_ENV_PLATFORM:
# 	By default, the env variable TRITON_CONDA_ENV_PLATFORM is set to cpu, if NVIDIA GPU is available, it will be set to gpu.
# 	Specify the env variable TRITON_CONDA_ENV_PLATFORM to override the default value.
# NVIDIA_VISIBLE_DEVICES:
# 	By default, the env variable NVIDIA_VISIBLE_DEVICES is set to all if NVIDIA GPU is available. Otherwise, it is unset.
#	Specify the env variable NVIDIA_VISIBLE_DEVICES to override the default value.
TRITON_CONDA_ENV_PLATFORM := ${TRITON_CONDA_ENV_PLATFORM}
NVIDIA_VISIBLE_DEVICES := ${NVIDIA_VISIBLE_DEVICES}
ifeq ($(shell nvidia-smi 2>/dev/null 1>&2; echo $$?),0)
	NVIDIA_GPU_AVAILABLE := true
	ifndef TRITON_CONDA_ENV_PLATFORM
		TRITON_CONDA_ENV_PLATFORM := gpu
	endif
	ifndef NVIDIA_VISIBLE_DEVICES
		NVIDIA_VISIBLE_DEVICES := all
	endif
else
	NVIDIA_GPU_AVAILABLE := false
	TRITON_CONDA_ENV_PLATFORM := cpu
endif

UNAME_S := $(shell uname -s)

CONTAINER_BUILD_NAME := model-build
CONTAINER_COMPOSE_NAME := model-dind
CONTAINER_COMPOSE_IMAGE_NAME := instill/model-compose
CONTAINER_BACKEND_INTEGRATION_TEST_NAME := model-backend-integration-test

HELM_NAMESPACE := instill-ai
HELM_RELEASE_NAME := model

#============================================================================

.PHONY: all
all:			## Launch all services with their up-to-date release version
	@make build-release
	@if ! (docker compose ls -q | grep -q "instill-base"); then \
		export TMP_CONFIG_DIR=$(shell mktemp -d) && \
		export SYSTEM_CONFIG_PATH=$(shell eval echo ${SYSTEM_CONFIG_PATH}) && \
		docker run --rm \
			-v /var/run/docker.sock:/var/run/docker.sock \
			-v $${TMP_CONFIG_DIR}:$${TMP_CONFIG_DIR} \
			-v $${SYSTEM_CONFIG_PATH}:$${SYSTEM_CONFIG_PATH} \
			--name ${CONTAINER_COMPOSE_NAME}-release \
			${CONTAINER_COMPOSE_IMAGE_NAME}:release /bin/sh -c " \
				cp /instill-ai/base/.env $${TMP_CONFIG_DIR}/.env && \
				cp /instill-ai/base/docker-compose.build.yml $${TMP_CONFIG_DIR}/docker-compose.build.yml && \
				cp -r /instill-ai/base/configs/influxdb $${TMP_CONFIG_DIR} && \
				/bin/sh -c 'cd /instill-ai/base && make all EDITION=$${EDITION:=local-ce} SYSTEM_CONFIG_PATH=$${SYSTEM_CONFIG_PATH} BUILD_CONFIG_DIR_PATH=$${TMP_CONFIG_DIR} OBSERVE_CONFIG_DIR_PATH=$${TMP_CONFIG_DIR}' && \
				rm -rf $${TMP_CONFIG_DIR}/* \
			" && \
		rm -rf $${TMP_CONFIG_DIR}; \
	fi
ifeq (${NVIDIA_GPU_AVAILABLE}, true)
	@docker inspect --type=image instill/tritonserver:${TRITON_SERVER_VERSION} >/dev/null 2>&1 || printf "\033[1;33mINFO:\033[0m This may take a while due to the enormous size of the Triton server image, but the image pulling process should be just a one-time effort.\n" && sleep 5
	@cat docker-compose.nvidia.yml | yq '.services.triton_server.deploy.resources.reservations.devices[0].device_ids |= (strenv(NVIDIA_VISIBLE_DEVICES) | split(",")) | ..style="double"' | \
		EDITION=$${EDITION:=local-ce} docker compose -f docker-compose.yml -f - up -d --quiet-pull
	@cat docker-compose.nvidia.yml | yq '.services.triton_server.deploy.resources.reservations.devices[0].device_ids |= (strenv(NVIDIA_VISIBLE_DEVICES) | split(",")) | ..style="double"' | \
		EDITION=$${EDITION:=local-ce} docker compose -f docker-compose.yml -f - rm -f
else
	@EDITION=$${EDITION:=local-ce} docker compose -f docker-compose.yml up -d --quiet-pull
	@EDITION=$${EDITION:=local-ce} docker compose -f docker-compose.yml rm -f
endif

.PHONY: latest
latest:			## Lunch all dependent services with their latest codebase
	@make build-latest
	@if ! (docker compose ls -q | grep -q "instill-base"); then \
		export TMP_CONFIG_DIR=$(shell mktemp -d) && \
		export SYSTEM_CONFIG_PATH=$(shell eval echo ${SYSTEM_CONFIG_PATH}) && \
		docker run --rm \
			-v /var/run/docker.sock:/var/run/docker.sock \
			-v $${TMP_CONFIG_DIR}:$${TMP_CONFIG_DIR} \
			-v $${SYSTEM_CONFIG_PATH}:$${SYSTEM_CONFIG_PATH} \
			--name ${CONTAINER_COMPOSE_NAME}-latest \
			${CONTAINER_COMPOSE_IMAGE_NAME}:latest /bin/sh -c " \
				cp /instill-ai/base/.env $${TMP_CONFIG_DIR}/.env && \
				cp /instill-ai/base/docker-compose.build.yml $${TMP_CONFIG_DIR}/docker-compose.build.yml && \
				cp -r /instill-ai/base/configs/influxdb $${TMP_CONFIG_DIR} && \
				/bin/sh -c 'cd /instill-ai/base && make latest PROFILE=all EDITION=$${EDITION:=local-ce:latest} BUILD_CONFIG_DIR_PATH=$${TMP_CONFIG_DIR} SYSTEM_CONFIG_PATH=$${SYSTEM_CONFIG_PATH} OBSERVE_CONFIG_DIR_PATH=$${TMP_CONFIG_DIR}' && \
				rm -rf $${TMP_CONFIG_DIR}/* \
			" && \
		rm -rf $${TMP_CONFIG_DIR}; \
	fi
ifeq (${NVIDIA_GPU_AVAILABLE}, true)
	@docker inspect --type=image instill/tritonserver:${TRITON_SERVER_VERSION} >/dev/null 2>&1 || printf "\033[1;33mINFO:\033[0m This may take a while due to the enormous size of the Triton server image, but the image pulling process should be just a one-time effort.\n" && sleep 5
	@cat docker-compose.nvidia.yml | yq '.services.triton_server.deploy.resources.reservations.devices[0].device_ids |= (strenv(NVIDIA_VISIBLE_DEVICES) | split(",")) | ..style="double"' | \
		COMPOSE_PROFILES=$(PROFILE) EDITION=$${EDITION:=local-ce:latest} docker compose -f docker-compose.yml -f docker-compose.latest.yml -f - up -d --quiet-pull
	@cat docker-compose.nvidia.yml | yq '.services.triton_server.deploy.resources.reservations.devices[0].device_ids |= (strenv(NVIDIA_VISIBLE_DEVICES) | split(",")) | ..style="double"' | \
		COMPOSE_PROFILES=$(PROFILE) EDITION=$${EDITION:=local-ce:latest} docker compose -f docker-compose.yml -f docker-compose.latest.yml  -f - rm -f
else
	@COMPOSE_PROFILES=$(PROFILE) EDITION=$${EDITION:=local-ce:latest} docker compose -f docker-compose.yml -f docker-compose.latest.yml up -d --quiet-pull
	@COMPOSE_PROFILES=$(PROFILE) EDITION=$${EDITION:=local-ce:latest} docker compose -f docker-compose.yml -f docker-compose.latest.yml rm -f
endif

.PHONY: logs
logs:			## Tail all logs with -n 10
	@docker compose logs --follow --tail=10

.PHONY: pull
pull:			## Pull all service images
	@docker inspect --type=image instill/tritonserver:${TRITON_SERVER_VERSION} >/dev/null 2>&1 || printf "\033[1;33mINFO:\033[0m This may take a while due to the enormous size of the Triton server image, but the image pulling process should be just a one-time effort.\n" && sleep 5
	@docker compose pull

.PHONY: stop
stop:			## Stop all components
	@docker compose stop

.PHONY: start
start:			## Start all stopped services
	@docker compose start

.PHONY: restart
restart:		## Restart all services
	@docker compose restart

.PHONY: rm
rm:				## Remove all stopped service containers
	@docker compose rm -f

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
	@EDITION=NULL docker compose down -v
	@if docker compose ls -q | grep -q "instill-base"; then \
		if docker image inspect ${CONTAINER_COMPOSE_IMAGE_NAME}:latest >/dev/null 2>&1; then \
			docker run --rm \
				-v /var/run/docker.sock:/var/run/docker.sock \
				--name ${CONTAINER_COMPOSE_NAME} \
				${CONTAINER_COMPOSE_IMAGE_NAME}:latest /bin/sh -c " \
					/bin/sh -c 'cd /instill-ai/base && make down' \
				"; \
		elif docker image inspect ${CONTAINER_COMPOSE_IMAGE_NAME}:release >/dev/null 2>&1; then \
			docker run --rm \
				-v /var/run/docker.sock:/var/run/docker.sock \
				--name ${CONTAINER_COMPOSE_NAME} \
				${CONTAINER_COMPOSE_IMAGE_NAME}:release /bin/sh -c " \
					/bin/sh -c 'cd /instill-ai/base && make down' \
				"; \
		fi	\
	fi


.PHONY: images
images:			## List all container images
	@docker compose images

.PHONY: ps
ps:				## List all service containers
	@docker compose ps

.PHONY: top
top:			## Display all running service processes
	@docker compose top

.PHONY: doc
doc:						## Run Redoc for OpenAPI spec at http://localhost:3001
	@docker compose up -d redoc_openapi

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
			docker compose -f docker-compose.build.yml build --progress plain \
		"

.PHONY: build-release
build-release:				## Build release images for all model components
	@docker build --progress plain \
		--build-arg INSTILL_BASE_VERSION=${INSTILL_BASE_VERSION} \
		--build-arg ALPINE_VERSION=${ALPINE_VERSION} \
		--build-arg GOLANG_VERSION=${GOLANG_VERSION} \
		--build-arg K6_VERSION=${K6_VERSION} \
		--build-arg CACHE_DATE="$(shell date)" \
		--build-arg MODEL_BACKEND_VERSION=${MODEL_BACKEND_VERSION} \
		--build-arg CONTROLLER_MODEL_VERSION=${CONTROLLER_MODEL_VERSION} \
		--target release \
		-t ${CONTAINER_COMPOSE_IMAGE_NAME}:release .
	@docker run --rm \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-v ${BUILD_CONFIG_DIR_PATH}/.env:/instill-ai/model/.env \
		-v ${BUILD_CONFIG_DIR_PATH}/docker-compose.build.yml:/instill-ai/model/docker-compose.build.yml \
		--name ${CONTAINER_BUILD_NAME}-release \
		${CONTAINER_COMPOSE_IMAGE_NAME}:release /bin/sh -c " \
			MODEL_BACKEND_VERSION=${MODEL_BACKEND_VERSION} \
			CONTROLLER_MODEL_VERSION=${CONTROLLER_MODEL_VERSION} \
			docker compose -f docker-compose.build.yml build --progress plain \
		"

.PHONY: integration-test-latest
integration-test-latest:			## Run integration test on the latest model
	@make latest PROFILE=all EDITION=local-ce:test
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
	@make all EDITION=local-ce:test
	@docker run --rm \
		--network instill-network \
		--name ${CONTAINER_BACKEND_INTEGRATION_TEST_NAME}-release \
		${CONTAINER_COMPOSE_IMAGE_NAME}:release /bin/sh -c " \
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
			cp /instill-ai/base/.env $${TMP_CONFIG_DIR}/.env && \
			cp /instill-ai/base/docker-compose.build.yml $${TMP_CONFIG_DIR}/docker-compose.build.yml && \
			/bin/sh -c 'cd /instill-ai/base && make build-latest BUILD_CONFIG_DIR_PATH=$${TMP_CONFIG_DIR}' && \
			/bin/sh -c 'cd /instill-ai/base && \
				helm install base charts/base \
					--namespace ${HELM_NAMESPACE} --create-namespace \
					--set edition=k8s-ce:test \
					--set apiGateway.image.tag=latest \
					--set mgmtBackend.image.tag=latest \
					--set console.image.tag=latest \
					--set tags.observability=false \
					--set tags.prometheusStack=false' \
			/bin/sh -c 'rm -rf $${TMP_CONFIG_DIR}/*' \
		" && rm -rf $${TMP_CONFIG_DIR}
	@kubectl rollout status deployment base-api-gateway --namespace ${HELM_NAMESPACE} --timeout=120s
	@export API_GATEWAY_POD_NAME=$$(kubectl get pods --namespace ${HELM_NAMESPACE} -l "app.kubernetes.io/component=api-gateway,app.kubernetes.io/instance=base" -o jsonpath="{.items[0].metadata.name}") && \
		kubectl --namespace ${HELM_NAMESPACE} port-forward $${API_GATEWAY_POD_NAME} ${API_GATEWAY_PORT}:${API_GATEWAY_PORT} > /dev/null 2>&1 &
	@while ! nc -vz localhost ${API_GATEWAY_PORT} > /dev/null 2>&1; do sleep 1; done
	@helm install ${HELM_RELEASE_NAME} charts/model --namespace ${HELM_NAMESPACE} --create-namespace \
		--set itMode.enabled=true \
		--set edition=k8s-ce:test \
		--set modelBackend.image.tag=latest \
		--set controllerModel.image.tag=latest \
		--set triton.nvidiaVisibleDevices=${NVIDIA_VISIBLE_DEVICES} \
		--set tags.observability=false
	@kubectl rollout status deployment model-model-backend --namespace instill-ai --timeout=120s
	@kubectl rollout status deployment model-controller-model --namespace instill-ai --timeout=180s
	@kubectl rollout status deployment model-triton-inference-server --namespace instill-ai --timeout=180s
	@sleep 10
ifeq ($(UNAME_S),Darwin)
	@docker run -t ----name ${CONTAINER_BACKEND_INTEGRATION_TEST_NAME}-helm-latest ${CONTAINER_COMPOSE_IMAGE_NAME}:latest /bin/sh -c " \
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
			/bin/sh -c 'cd /instill-ai/base && helm uninstall base --namespace ${HELM_NAMESPACE}' \
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
		${CONTAINER_COMPOSE_IMAGE_NAME}:release /bin/sh -c " \
			/bin/sh -c 'cd /instill-ai/base && \
				export $(grep -v '^#' .env | xargs) && \
				helm install base charts/base \
					--namespace ${HELM_NAMESPACE} --create-namespace \
					--set edition=k8s-ce:test \
					--set apiGateway.image.tag=${API_GATEWAY_VERSION} \
					--set mgmtBackend.image.tag=${MGMT_BACKEND_VERSION} \
					--set tags.observability=false \
					--set tags.prometheusStack=false' \
		"
	@kubectl rollout status deployment base-api-gateway --namespace ${HELM_NAMESPACE} --timeout=120s
	@export API_GATEWAY_POD_NAME=$$(kubectl get pods --namespace ${HELM_NAMESPACE} -l "app.kubernetes.io/component=api-gateway,app.kubernetes.io/instance=base" -o jsonpath="{.items[0].metadata.name}") && \
		kubectl --namespace ${HELM_NAMESPACE} port-forward $${API_GATEWAY_POD_NAME} ${API_GATEWAY_PORT}:${API_GATEWAY_PORT} > /dev/null 2>&1 &
	@while ! nc -vz localhost ${API_GATEWAY_PORT} > /dev/null 2>&1; do sleep 1; done
	@helm install ${HELM_RELEASE_NAME} charts/model --namespace ${HELM_NAMESPACE} --create-namespace \
		--set itMode.enabled=true \
		--set edition=k8s-ce:test \
		--set modelBackend.image.tag=${MODEL_BACKEND_VERSION} \
		--set controllerModel.image.tag=${CONTROLLER_MODEL_VERSION} \
		--set triton.nvidiaVisibleDevices=${NVIDIA_VISIBLE_DEVICES} \
		--set tags.observability=false
	@kubectl rollout status deployment model-model-backend --namespace instill-ai --timeout=120s
	@kubectl rollout status deployment model-controller-model --namespace instill-ai --timeout=180s
	@kubectl rollout status deployment model-triton-inference-server --namespace instill-ai --timeout=180s
	@sleep 10
ifeq ($(UNAME_S),Darwin)
	@docker run --rm --name ${CONTAINER_BACKEND_INTEGRATION_TEST_NAME}-helm-release ${CONTAINER_COMPOSE_IMAGE_NAME}:release /bin/sh -c " \
			/bin/sh -c 'cd model-backend && make integration-test API_GATEWAY_URL=host.docker.internal:${API_GATEWAY_PORT}' && \
			/bin/sh -c 'cd controller-model && make integration-test API_GATEWAY_URL=host.docker.internal:${API_GATEWAY_PORT}' \
		"
else ifeq ($(UNAME_S),Linux)
	@docker run --rm --network host --name ${CONTAINER_BACKEND_INTEGRATION_TEST_NAME}-helm-release ${CONTAINER_COMPOSE_IMAGE_NAME}:release /bin/sh -c " \
			/bin/sh -c 'cd model-backend && make integration-test API_GATEWAY_URL=localhost:${API_GATEWAY_PORT}' && \
			/bin/sh -c 'cd controller-model && make integration-test API_GATEWAY_URL=localhost:${API_GATEWAY_PORT}' \
		"
endif
	@helm uninstall ${HELM_RELEASE_NAME} --namespace ${HELM_NAMESPACE}
	@docker run --rm \
		-v ${HOME}/.kube/config:/root/.kube/config \
		${DOCKER_HELM_IT_EXTRA_PARAMS} \
		--name ${CONTAINER_BACKEND_INTEGRATION_TEST_NAME}-release \
		${CONTAINER_COMPOSE_IMAGE_NAME}:release /bin/sh -c " \
			/bin/sh -c 'cd /instill-ai/base && helm uninstall base --namespace ${HELM_NAMESPACE}' \
		"
	@kubectl delete namespace ${HELM_NAMESPACE}
	@pkill -f "port-forward"
	@make down

.PHONY: help
help:       	## Show this help
	@echo "\nMake Application with Docker Compose"
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m (default: help)\n\nTargets:\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-32s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)
