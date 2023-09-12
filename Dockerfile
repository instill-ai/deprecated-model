ARG UBUNTU_VERSION
FROM ubuntu:${UBUNTU_VERSION} AS base

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get -y install \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

RUN mkdir -p /etc/apt/keyrings
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
RUN echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

RUN apt-get update && apt-get install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-compose-plugin \
    git \
    bash \
    make \
    wget \
    vim && rm -rf /var/lib/apt/lists/*

# Install k6
ARG TARGETARCH K6_VERSION
ADD https://github.com/grafana/k6/releases/download/v${K6_VERSION}/k6-v${K6_VERSION}-linux-${TARGETARCH}.tar.gz k6-v${K6_VERSION}-linux-${TARGETARCH}.tar.gz
RUN tar -xf k6-v${K6_VERSION}-linux-${TARGETARCH}.tar.gz --strip-components 1 -C /usr/bin

# Install Helm
RUN curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Install Kubectl
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/${TARGETARCH}/kubectl
RUN chmod +x ./kubectl
RUN mv ./kubectl /usr/local/bin

FROM ubuntu:${UBUNTU_VERSION} AS latest

COPY --from=base /etc /etc
COPY --from=base /usr /usr
COPY --from=docker:dind /usr/local/bin /usr/local/bin

ARG CACHE_DATE
RUN echo "Model latest codebase cloned on ${CACHE_DATE}"

WORKDIR /instill-ai

RUN git clone https://github.com/instill-ai/base.git

WORKDIR /instill-ai/model

RUN git clone https://github.com/instill-ai/model-backend.git
RUN git clone https://github.com/instill-ai/controller-model.git

FROM ubuntu:${UBUNTU_VERSION} AS release

COPY --from=base /etc /etc
COPY --from=base /usr /usr
COPY --from=docker:dind /usr/local/bin /usr/local/bin

ARG CACHE_DATE
RUN echo "Model release codebase cloned on ${CACHE_DATE}"

WORKDIR /instill-ai

ARG INSTILL_BASE_VERSION
RUN git clone -b v${INSTILL_BASE_VERSION} -c advice.detachedHead=false https://github.com/instill-ai/base.git

WORKDIR /instill-ai/model

ARG MODEL_BACKEND_VERSION CONTROLLER_MODEL_VERSION
RUN git clone -b v${MODEL_BACKEND_VERSION} -c advice.detachedHead=false https://github.com/instill-ai/model-backend.git
RUN git clone -b v${CONTROLLER_MODEL_VERSION} -c advice.detachedHead=false https://github.com/instill-ai/controller-model.git
