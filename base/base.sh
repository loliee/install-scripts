#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

if lsb_release -a 2>/dev/null | grep Debian; then
  set -x \
    && export DEBIAN_FRONTEND=noninteractive \
    && apt-get update \
    && apt-get install -y \
      automake \
      bc \
      bzip2 \
      curl \
      git \
      htop \
      jq \
      iotop \
      lsof \
      libssl-dev \
      libyaml-dev \
      nmap \
      net-tools \
      software-properties-common \
      rsync \
      socat \
      strace \
      tcpdump \
      ufw \
      unzip \
      vim \
      zip
fi
