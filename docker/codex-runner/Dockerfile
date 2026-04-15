FROM ubuntu:24.04

ARG TARGETARCH
ARG RUNNER_VERSION=latest

ENV DEBIAN_FRONTEND=noninteractive
ENV ACTIONS_RUNNER_DIR=/home/runner/actions-runner
ENV RUNNER_WORKDIR=_work

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      bash \
      build-essential \
      ca-certificates \
      curl \
      git \
      gnupg \
      jq \
      openssh-client \
      pkg-config \
      python3 \
      python3-pip \
      sudo \
      tar \
      unzip \
      xz-utils \
      zip && \
    rm -rf /var/lib/apt/lists/*

RUN install -d -m 0755 /etc/apt/keyrings && \
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | \
      gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_22.x nodistro main" \
      > /etc/apt/sources.list.d/nodesource.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends nodejs && \
    npm install -g @openai/codex && \
    npm cache clean --force && \
    rm -rf /var/lib/apt/lists/*

RUN useradd --create-home --shell /bin/bash runner && \
    mkdir -p "${ACTIONS_RUNNER_DIR}/${RUNNER_WORKDIR}" /home/runner/.codex && \
    chown -R runner:runner /home/runner

WORKDIR ${ACTIONS_RUNNER_DIR}

RUN set -eux; \
    docker_arch="${TARGETARCH:-$(dpkg --print-architecture)}"; \
    case "${docker_arch}" in \
      amd64) runner_arch="x64" ;; \
      arm64) runner_arch="arm64" ;; \
      *) echo "Unsupported Docker target architecture: ${docker_arch}" >&2; exit 1 ;; \
    esac; \
    version="${RUNNER_VERSION}"; \
    if [[ "${version}" == "latest" ]]; then \
      version="$(curl -fsSL https://api.github.com/repos/actions/runner/releases/latest | jq -r '.tag_name' | sed 's/^v//')"; \
    fi; \
    curl -fsSL \
      -o actions-runner.tar.gz \
      "https://github.com/actions/runner/releases/download/v${version}/actions-runner-linux-${runner_arch}-${version}.tar.gz"; \
    tar -xzf actions-runner.tar.gz; \
    rm actions-runner.tar.gz; \
    ./bin/installdependencies.sh; \
    chown -R runner:runner /home/runner

COPY docker/codex-runner/entrypoint.sh /usr/local/bin/codex-runner-entrypoint
RUN chmod +x /usr/local/bin/codex-runner-entrypoint

USER runner

ENTRYPOINT ["/usr/local/bin/codex-runner-entrypoint"]
