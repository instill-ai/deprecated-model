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
CONTAINER_CONSOLE_INTEGRATION_TEST_NAME := model-console-integration-test

HELM_NAMESPACE := instill-ai
HELM_RELEASE_NAME := model

#============================================================================

.PHONY: all
all:			## Launch all services with their up-to-date release version
	@if ! (docker compose ls -q | grep -q "instill-base"); then \
		export TMP_CONFIG_DIR=$(shell mktemp -d) && \
		docker run -it --rm \
			-v /var/run/docker.sock:/var/run/docker.sock \
			-v $${TMP_CONFIG_DIR}:$${TMP_CONFIG_DIR} \
			--name ${CONTAINER_COMPOSE_NAME}-release \
			${CONTAINER_COMPOSE_IMAGE_NAME}:release /bin/bash -c " \
				cp -r /instill-ai/base/configs/* $${TMP_CONFIG_DIR} && \
				/bin/bash -c 'cd /instill-ai/base && make all EDITION=local-ce OBSERVE_ENABLED=${OBSERVE_ENABLED} OBSERVE_CONFIG_DIR_PATH=$${TMP_CONFIG_DIR}' && \
				/bin/bash -c 'rm -r $${TMP_CONFIG_DIR}/*' \
			" && \
		rm -r $${TMP_CONFIG_DIR}; \
	fi
ifeq (${NVIDIA_GPU_AVAILABLE}, true)
	@docker inspect --type=image instill/tritonserver:${TRITON_SERVER_VERSION} >/dev/null 2>&1 || printf "\033[1;33mINFO:\033[0m This may take a while due to the enormous size of the Triton server image, but the image pulling process should be just a one-time effort.\n" && sleep 5
	@cat docker-compose.nvidia.yml | yq '.services.triton_server.deploy.resources.reservations.devices[0].device_ids |= (strenv(NVIDIA_VISIBLE_DEVICES) | split(",")) | ..style="double"' | \
		EDITION=local-ce docker compose -f docker-compose.yml -f - up -d --quiet-pull
	@cat docker-compose.nvidia.yml | yq '.services.triton_server.deploy.resources.reservations.devices[0].device_ids |= (strenv(NVIDIA_VISIBLE_DEVICES) | split(",")) | ..style="double"' | \
		EDITION=local-ce docker compose -f docker-compose.yml -f - rm -f
else
	@EDITION=local-ce docker compose -f docker-compose.yml up -d --quiet-pull
	@EDITION=local-ce docker compose -f docker-compose.yml rm -f
endif

.PHONY: latest
latest:			## Lunch all dependent services with their latest codebase
	@if ! (docker compose ls -q | grep -q "instill-base"); then \
		export TMP_CONFIG_DIR=$(shell mktemp -d) && \
		docker run -it --rm \
			-v /var/run/docker.sock:/var/run/docker.sock \
			-v $${TMP_CONFIG_DIR}:$${TMP_CONFIG_DIR} \
			--name ${CONTAINER_COMPOSE_NAME}-latest \
			${CONTAINER_COMPOSE_IMAGE_NAME}:latest /bin/bash -c " \
				cp -r /instill-ai/base/configs/* $${TMP_CONFIG_DIR} && \
				/bin/bash -c 'cd /instill-ai/base && make latest EDITION=local-ce:latest PROFILE=$(PROFILE) OBSERVE_ENABLED=${OBSERVE_ENABLED} OBSERVE_CONFIG_DIR_PATH=$${TMP_CONFIG_DIR}' && \
				/bin/bash -c 'rm -r $${TMP_CONFIG_DIR}/*' \
			" && \
		rm -r $${TMP_CONFIG_DIR}; \
	fi
ifeq (${NVIDIA_GPU_AVAILABLE}, true)
	@docker inspect --type=image instill/tritonserver:${TRITON_SERVER_VERSION} >/dev/null 2>&1 || printf "\033[1;33mINFO:\033[0m This may take a while due to the enormous size of the Triton server image, but the image pulling process should be just a one-time effort.\n" && sleep 5
	@cat docker-compose.nvidia.yml | yq '.services.triton_server.deploy.resources.reservations.devices[0].device_ids |= (strenv(NVIDIA_VISIBLE_DEVICES) | split(",")) | ..style="double"' | \
		COMPOSE_PROFILES=$(PROFILE) EDITION=local-ce:latest docker compose -f docker-compose.yml -f docker-compose.latest.yml -f - up -d --quiet-pull
	@cat docker-compose.nvidia.yml | yq '.services.triton_server.deploy.resources.reservations.devices[0].device_ids |= (strenv(NVIDIA_VISIBLE_DEVICES) | split(",")) | ..style="double"' | \
		COMPOSE_PROFILES=$(PROFILE) EDITION=local-ce:latest docker compose -f docker-compose.yml -f docker-compose.latest.yml  -f - rm -f
else
	@COMPOSE_PROFILES=$(PROFILE) EDITION=local-ce:latest docker compose -f docker-compose.yml -f docker-compose.latest.yml up -d --quiet-pull
	@COMPOSE_PROFILES=$(PROFILE) EDITION=local-ce:latest docker compose -f docker-compose.yml -f docker-compose.latest.yml rm -f
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
	@docker rm -f ${CONTAINER_CONSOLE_INTEGRATION_TEST_NAME}-latest >/dev/null 2>&1
	@docker rm -f ${CONTAINER_BACKEND_INTEGRATION_TEST_NAME}-release >/dev/null 2>&1
	@docker rm -f ${CONTAINER_CONSOLE_INTEGRATION_TEST_NAME}-release >/dev/null 2>&1
	@docker rm -f ${CONTAINER_BACKEND_INTEGRATION_TEST_NAME}-helm-latest >/dev/null 2>&1
	@docker rm -f ${CONTAINER_CONSOLE_INTEGRATION_TEST_NAME}-helm-latest >/dev/null 2>&1
	@docker rm -f ${CONTAINER_BACKEND_INTEGRATION_TEST_NAME}-helm-release >/dev/null 2>&1
	@docker rm -f ${CONTAINER_CONSOLE_INTEGRATION_TEST_NAME}-helm-release >/dev/null 2>&1
	@docker rm -f ${CONTAINER_COMPOSE_NAME}-latest >/dev/null 2>&1
	@docker rm -f ${CONTAINER_COMPOSE_NAME}-release >/dev/null 2>&1
	@docker compose down -v
	@if docker compose ls -q | grep -q "instill-base"; then \
		docker run -it --rm \
			-v /var/run/docker.sock:/var/run/docker.sock \
			--name ${CONTAINER_COMPOSE_NAME} \
			${CONTAINER_COMPOSE_IMAGE_NAME}:latest /bin/bash -c " \
				/bin/bash -c 'cd /instill-ai/base && make down' \
			"; \
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
		--build-arg UBUNTU_VERSION=${UBUNTU_VERSION} \
		--build-arg GOLANG_VERSION=${GOLANG_VERSION} \
		--build-arg K6_VERSION=${K6_VERSION} \
		--build-arg CACHE_DATE="$(shell date)" \
		--target latest \
		-t ${CONTAINER_COMPOSE_IMAGE_NAME}:latest .
	@docker run -it --rm \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-v ${BUILD_CONFIG_DIR_PATH}/.env:/instill-ai/model/.env \
		-v ${BUILD_CONFIG_DIR_PATH}/docker-compose.build.yml:/instill-ai/model/docker-compose.build.yml \
		--name ${CONTAINER_BUILD_NAME}-latest \
		${CONTAINER_COMPOSE_IMAGE_NAME}:latest /bin/bash -c " \
			API_GATEWAY_VERSION=latest \
			MODEL_BACKEND_VERSION=latest \
			MGMT_BACKEND_VERSION=latest \
			CONTROLLER_MODEL_VERSION=latest \
			docker compose -f docker-compose.build.yml build --progress plain \
		"

.PHONY: build-release
build-release:				## Build release images for all model components
	@docker build --progress plain \
		--build-arg UBUNTU_VERSION=${UBUNTU_VERSION} \
		--build-arg GOLANG_VERSION=${GOLANG_VERSION} \
		--build-arg K6_VERSION=${K6_VERSION} \
		--build-arg CACHE_DATE="$(shell date)" \
		--build-arg API_GATEWAY_VERSION=${API_GATEWAY_VERSION} \
		--build-arg MODEL_BACKEND_VERSION=${MODEL_BACKEND_VERSION} \
		--build-arg CONTROLLER_MODEL_VERSION=${CONTROLLER_MODEL_VERSION} \
		--build-arg CONSOLE_VERSION=${CONSOLE_VERSION} \
		--target release \
		-t ${CONTAINER_COMPOSE_IMAGE_NAME}:release .
	@docker run -it --rm \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-v ${BUILD_CONFIG_DIR_PATH}/.env:/instill-ai/model/.env \
		-v ${BUILD_CONFIG_DIR_PATH}/docker-compose.build.yml:/instill-ai/model/docker-compose.build.yml \
		--name ${CONTAINER_BUILD_NAME}-release \
		${CONTAINER_COMPOSE_IMAGE_NAME}:release /bin/bash -c " \
			API_GATEWAY_VERSION=${API_GATEWAY_VERSION} \
			MODEL_BACKEND_VERSION=${MODEL_BACKEND_VERSION} \
			MGMT_BACKEND_VERSION=${MGMT_BACKEND_VERSION} \
			CONTROLLER_MODEL_VERSION=${CONTROLLER_MODEL_VERSION} \
			CONSOLE_VERSION=${CONSOLE_VERSION} \
			docker compose -f docker-compose.build.yml build --progress plain \
		"

.PHONY: integration-test-latest
integration-test-latest:			## Run integration test on the latest model
	@make build-latest
	@export TMP_CONFIG_DIR=$(shell mktemp -d) && docker run -it --rm \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-v $${TMP_CONFIG_DIR}:$${TMP_CONFIG_DIR} \
		--name ${CONTAINER_BACKEND_INTEGRATION_TEST_NAME}-latest \
		${CONTAINER_COMPOSE_IMAGE_NAME}:latest /bin/bash -c " \
			cp /instill-ai/base/.env $${TMP_CONFIG_DIR}/.env && \
			cp /instill-ai/base/docker-compose.build.yml $${TMP_CONFIG_DIR}/docker-compose.build.yml && \
			cp -r /instill-ai/base/configs/influxdb $${TMP_CONFIG_DIR} && \
			/bin/bash -c 'cd /instill-ai/base && make build-latest BUILD_CONFIG_DIR_PATH=$${TMP_CONFIG_DIR}' && \
			/bin/bash -c 'cd /instill-ai/base && COMPOSE_PROFILES=all EDITION=local-ce:test OBSERVE_CONFIG_DIR_PATH=$${TMP_CONFIG_DIR} docker compose -f docker-compose.yml -f docker-compose.latest.yml up -d --quiet-pull' && \
			/bin/bash -c 'cd /instill-ai/base && COMPOSE_PROFILES=all EDITION=local-ce:test OBSERVE_CONFIG_DIR_PATH=$${TMP_CONFIG_DIR} docker compose -f docker-compose.yml -f docker-compose.latest.yml rm -f' && \
			/bin/bash -c 'rm -r $${TMP_CONFIG_DIR}/*' \
		" && rm -r $${TMP_CONFIG_DIR}
	@COMPOSE_PROFILES=all EDITION=local-ce:test ITMODE_ENABLED=true docker compose -f docker-compose.yml -f docker-compose.latest.yml up -d --quiet-pull
	@COMPOSE_PROFILES=all EDITION=local-ce:test ITMODE_ENABLED=true docker compose -f docker-compose.yml -f docker-compose.latest.yml rm -f
	@docker run -it --rm \
		--network instill-network \
		--name ${CONTAINER_BACKEND_INTEGRATION_TEST_NAME}-latest \
		${CONTAINER_COMPOSE_IMAGE_NAME}:latest /bin/bash -c " \
			/bin/bash -c 'cd model-backend && make integration-test API_GATEWAY_MODEL_HOST=${API_GATEWAY_MODEL_HOST} API_GATEWAY_MODEL_PORT=${API_GATEWAY_MODEL_PORT}' && \
			/bin/bash -c 'cd controller-model && make integration-test API_GATEWAY_MODEL_HOST=${API_GATEWAY_MODEL_HOST} API_GATEWAY_MODEL_PORT=${API_GATEWAY_MODEL_PORT}' \
		"
	@make down

.PHONY: integration-test-release
integration-test-release:			## Run integration test on the release model
	@make build-release
	@export TMP_CONFIG_DIR=$(shell mktemp -d) && docker run -it --rm \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-v $${TMP_CONFIG_DIR}:$${TMP_CONFIG_DIR} \
		--name ${CONTAINER_BACKEND_INTEGRATION_TEST_NAME}-release \
		${CONTAINER_COMPOSE_IMAGE_NAME}:release /bin/bash -c " \
			cp /instill-ai/base/.env $${TMP_CONFIG_DIR}/.env && \
			cp /instill-ai/base/docker-compose.build.yml $${TMP_CONFIG_DIR}/docker-compose.build.yml && \
			cp -r /instill-ai/base/configs/influxdb $${TMP_CONFIG_DIR} && \
			/bin/bash -c 'cd /instill-ai/base && make build-release BUILD_CONFIG_DIR_PATH=$${TMP_CONFIG_DIR}' \
			/bin/bash -c 'cd /instill-ai/base && EDITION=local-ce:test OBSERVE_CONFIG_DIR_PATH=$${TMP_CONFIG_DIR} docker compose up -d --quiet-pull' && \
			/bin/bash -c 'cd /instill-ai/base && EDITION=local-ce:test OBSERVE_CONFIG_DIR_PATH=$${TMP_CONFIG_DIR} docker compose rm -f' && \
			/bin/bash -c 'rm -r $${TMP_CONFIG_DIR}/*' \
		" && rm -r $${TMP_CONFIG_DIR}
	@EDITION=local-ce:test ITMODE_ENABLED=true docker compose up -d --quiet-pull
	@EDITION=local-ce:test ITMODE_ENABLED=true docker compose rm -f
	@docker run -it --rm \
		--network instill-network \
		--name ${CONTAINER_BACKEND_INTEGRATION_TEST_NAME}-release \
		${CONTAINER_COMPOSE_IMAGE_NAME}:release /bin/bash -c " \
			/bin/bash -c 'cd model-backend && make integration-test API_GATEWAY_MODEL_HOST=${API_GATEWAY_MODEL_HOST} API_GATEWAY_MODEL_PORT=${API_GATEWAY_MODEL_PORT}' && \
			/bin/bash -c 'cd controller-model && make integration-test API_GATEWAY_MODEL_HOST=${API_GATEWAY_MODEL_HOST} API_GATEWAY_MODEL_PORT=${API_GATEWAY_MODEL_PORT}' \
		"
	@make down

.PHONY: helm-integration-test-latest
helm-integration-test-latest:                       ## Run integration test on the Helm latest for model
	@make build-latest
	@docker run -it --rm \
		-v ${HOME}/.kube/config:/instill-ai/kubeconfig \
		--name ${CONTAINER_BACKEND_INTEGRATION_TEST_NAME}-latest \
		${CONTAINER_COMPOSE_IMAGE_NAME}:latest /bin/bash -c " \
			/bin/bash -c 'cd /instill-ai/base && \
				helm --kubeconfig /instill-ai/kubeconfig install base charts/base \
					--namespace ${HELM_NAMESPACE} --create-namespace \
					--set edition=k8s-ce:test \
					--set apiGatewayBase.image.tag=latest \
					--set mgmtBackend.image.tag=latest \
					--set console.image.tag=latest \
					--set tags.observability=false \
					--set tags.prometheusStack=false' \
		"
	@kubectl rollout status deployment base-api-gateway-base --namespace ${HELM_NAMESPACE} --timeout=120s
	@helm install ${HELM_RELEASE_NAME} charts/model --namespace ${HELM_NAMESPACE} --create-namespace \
		--set itMode.enabled=true \
		--set edition=k8s-ce:test \
		--set apiGatewayModel.image.tag=latest \
		--set modelBackend.image.tag=latest \
		--set controllerModel.image.tag=latest \
		--set triton.nvidiaVisibleDevices=${NVIDIA_VISIBLE_DEVICES} \
		--set tags.observability=false
	@kubectl rollout status deployment model-api-gateway-model --namespace ${HELM_NAMESPACE} --timeout=120s
	@export API_GATEWAY_MODEL_POD_NAME=$$(kubectl get pods --namespace ${HELM_NAMESPACE} -l "app.kubernetes.io/component=api-gateway-model,app.kubernetes.io/instance=${HELM_RELEASE_NAME}" -o jsonpath="{.items[0].metadata.name}") && \
		kubectl --namespace ${HELM_NAMESPACE} port-forward $${API_GATEWAY_MODEL_POD_NAME} ${API_GATEWAY_MODEL_PORT}:${API_GATEWAY_MODEL_PORT} > /dev/null 2>&1 &
	@while ! nc -vz localhost ${API_GATEWAY_MODEL_PORT} > /dev/null 2>&1; do sleep 1; done
	@sleep 5
ifeq ($(UNAME_S),Darwin)
	@docker run -it --rm --name ${CONTAINER_BACKEND_INTEGRATION_TEST_NAME}-helm-latest ${CONTAINER_COMPOSE_IMAGE_NAME}:latest /bin/bash -c " \
			/bin/bash -c 'cd model-backend && make integration-test API_GATEWAY_MODEL_HOST=host.docker.internal API_GATEWAY_MODEL_PORT=${API_GATEWAY_MODEL_PORT}' && \
			/bin/bash -c 'cd controller-model && make integration-test API_GATEWAY_MODEL_HOST=host.docker.internal API_GATEWAY_MODEL_PORT=${API_GATEWAY_MODEL_PORT}' \
		"
else ifeq ($(UNAME_S),Linux)
	@docker run -it --rm --network host --name ${CONTAINER_BACKEND_INTEGRATION_TEST_NAME}-helm-latest ${CONTAINER_COMPOSE_IMAGE_NAME}:latest /bin/bash -c " \
			/bin/bash -c 'cd model-backend && make integration-test API_GATEWAY_MODEL_HOST=localhost API_GATEWAY_MODEL_PORT=${API_GATEWAY_MODEL_PORT}' && \
			/bin/bash -c 'cd controller-model && make integration-test API_GATEWAY_MODEL_HOST=localhost API_GATEWAY_MODEL_PORT=${API_GATEWAY_MODEL_PORT}' \
		"
endif
	@helm uninstall ${HELM_RELEASE_NAME} --namespace ${HELM_NAMESPACE}
	@docker run -it --rm \
		-v ${HOME}/.kube/config:/instill-ai/kubeconfig \
		--name ${CONTAINER_BACKEND_INTEGRATION_TEST_NAME}-latest \
		${CONTAINER_COMPOSE_IMAGE_NAME}:latest /bin/bash -c " \
			/bin/bash -c 'cd /instill-ai/base && helm --kubeconfig /instill-ai/kubeconfig uninstall base --namespace ${HELM_NAMESPACE}' \
		"
	@kubectl delete namespace instill-ai
	@pkill -f "port-forward"
	@make down

.PHONY: helm-integration-test-release
helm-integration-test-release:                       ## Run integration test on the Helm release for model)
	@make build-release
	@docker run -it --rm \
		-v ${HOME}/.kube/config:/instill-ai/kubeconfig \
		--name ${CONTAINER_BACKEND_INTEGRATION_TEST_NAME}-latest \
		${CONTAINER_COMPOSE_IMAGE_NAME}:latest /bin/bash -c " \
			/bin/bash -c 'cd /instill-ai/base && \
				export $(grep -v '^#' .env | xargs) && \
				helm --kubeconfig /instill-ai/kubeconfig install base charts/base \
					--namespace ${HELM_NAMESPACE} --create-namespace \
					--set edition=k8s-ce:test \
					--set apiGatewayBase.image.tag=$${API_GATEWAY_BASE_VERSION} \
					--set mgmtBackend.image.tag=$${MGMT_BACKEND_VERSION} \
					--set console.image.tag=$${CONSOLE_VERSION} \
					--set tags.observability=false \
					--set tags.prometheusStack=false' \
		"
	@kubectl rollout status deployment base-api-gateway-base --namespace ${HELM_NAMESPACE} --timeout=120s
	@helm install ${HELM_RELEASE_NAME} charts/model --namespace ${HELM_NAMESPACE} --create-namespace \
		--set itMode.enabled=true \
		--set edition=k8s-ce:test \
		--set apiGatewayModel.image.tag=${API_GATEWAY_VERSION} \
		--set modelBackend.image.tag=${MODEL_BACKEND_VERSION} \
		--set controllerModel.image.tag=latest \
		--set triton.nvidiaVisibleDevices=${NVIDIA_VISIBLE_DEVICES} \
		--set tags.observability=false
	@kubectl rollout status deployment model-api-gateway-model --namespace ${HELM_NAMESPACE} --timeout=120s
	@export API_GATEWAY_MODEL_POD_NAME=$$(kubectl get pods --namespace ${HELM_NAMESPACE} -l "app.kubernetes.io/component=api-gateway-model,app.kubernetes.io/instance=${HELM_RELEASE_NAME}" -o jsonpath="{.items[0].metadata.name}") && \
		kubectl --namespace ${HELM_NAMESPACE} port-forward $${API_GATEWAY_MODEL_POD_NAME} ${API_GATEWAY_MODEL_PORT}:${API_GATEWAY_MODEL_PORT} > /dev/null 2>&1 &
	@while ! nc -vz localhost ${API_GATEWAY_MODEL_PORT} > /dev/null 2>&1; do sleep 1; done
	@sleep 5
ifeq ($(UNAME_S),Darwin)
	@docker run -it --rm --name ${CONTAINER_BACKEND_INTEGRATION_TEST_NAME}-helm-release ${CONTAINER_COMPOSE_IMAGE_NAME}:release /bin/bash -c " \
			/bin/bash -c 'cd model-backend && make integration-test API_GATEWAY_MODEL_HOST=host.docker.internal API_GATEWAY_MODEL_PORT=${API_GATEWAY_MODEL_PORT}' && \
			/bin/bash -c 'cd controller-model && make integration-test API_GATEWAY_MODEL_HOST=host.docker.internal API_GATEWAY_MODEL_PORT=${API_GATEWAY_MODEL_PORT}' \
		"
else ifeq ($(UNAME_S),Linux)
	@docker run -it --rm --network host --name ${CONTAINER_BACKEND_INTEGRATION_TEST_NAME}-helm-release ${CONTAINER_COMPOSE_IMAGE_NAME}:release /bin/bash -c " \
			/bin/bash -c 'cd model-backend && make integration-test API_GATEWAY_MODEL_HOST=host.docker.internal API_GATEWAY_MODEL_PORT=${API_GATEWAY_MODEL_PORT}' && \
			/bin/bash -c 'cd controller-model && make integration-test API_GATEWAY_MODEL_HOST=host.docker.internal API_GATEWAY_MODEL_PORT=${API_GATEWAY_MODEL_PORT}' \
		"
endif
	@helm uninstall ${HELM_RELEASE_NAME} --namespace ${HELM_NAMESPACE}
	@docker run -it --rm \
		-v ${HOME}/.kube/config:/instill-ai/kubeconfig \
		--name ${CONTAINER_BACKEND_INTEGRATION_TEST_NAME}-latest \
		${CONTAINER_COMPOSE_IMAGE_NAME}:latest /bin/bash -c " \
			/bin/bash -c 'cd /instill-ai/base && helm --kubeconfig /instill-ai/kubeconfig uninstall base --namespace ${HELM_NAMESPACE}' \
		"
	@kubectl delete namespace instill-ai
	@pkill -f "port-forward"
	@make down

.PHONY: help
help:       	## Show this help
	@echo "\nMake Application with Docker Compose"
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m (default: help)\n\nTargets:\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-32s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)
