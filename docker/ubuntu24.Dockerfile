FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    bash \
    ca-certificates \
    curl \
    git \
    gpg \
    sudo \
    unzip \
    wget \
    xz-utils \
    zip \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace

COPY scripts/setup/ubuntu24 /tmp/repo/scripts/setup/ubuntu24
COPY config/toolchains.yml /tmp/repo/config/toolchains.yml
RUN /tmp/repo/scripts/setup/ubuntu24/install-toolchains.sh --group primary --install-root /opt/ai-coding-lang-bench

ENV BASH_ENV=/opt/ai-coding-lang-bench/env.sh
RUN echo 'source /opt/ai-coding-lang-bench/env.sh' >> /etc/bash.bashrc
