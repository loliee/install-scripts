#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

DOCKER_VERSION=${DOCKER_VERSION:-'1.12.1'}
DOCKER_COMPOSE_VERSION=${DOCKER_COMPOSE_VERSION:-'1.8.0'}

export DEBIAN_FRONTEND=noninteractive

# Ensure version directory exists
mkdir -p /root/.versions

# Ensure git is installed
hash git &>/dev/null || apt-get install -y git

# Ensure curl is installed
hash curl &>/dev/null || apt-get install -y curl

# Ensure dependencies are installed
apt-get install -y \
  apt-transport-https \
  aufs-tools \
  ca-certificates \
  xz-utils \
  --no-install-recommends

apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D

echo "Prepare docker ${DOCKER_VERSION} release ..."
grep -q "^${DOCKER_VERSION}" /root/.versions/docker &>/dev/null || {
  # Prepare for docker
  apt-get purge -f "lxc-docker*" &>/dev/null || true
  apt-get purge -f "docker.io*" &>/dev/null || true
  apt-cache policy docker-engine
  apt-get purge lxc-docker &>/dev/null || true

  # Ubuntu
  if [[ $(lsb_release -c --short) == 'trusty' ]]; then
    echo 'docker detected OS "Ubuntu"'

    if [[ ! -f /etc/apt/sources.list.d/docker.list ]]; then
      echo 'deb https://apt.dockerproject.org/repo ubuntu-trusty main' > /etc/apt/sources.list.d/docker.list
    fi

    apt-get install -y \
      "linux-image-extra-$(uname -r)" \
      "linux-image-extra-virtual"

    # https://github.com/docker/docker/issues/20221
    rm -rf /var/lib/docker/devicemapper || true
    rm -rf /var/lib/docker/network || true
  # Debian
  elif [ -f "/etc/debian_version" ]; then
    echo 'docker detected OS "Debian"'

    if [[ ! -f /etc/apt/sources.list.d/docker.list ]]; then
      echo "deb https://apt.dockerproject.org/repo debian-jessie main" >> /etc/apt/sources.list.d/docker.list
    fi
    apt-get install -y linux-headers-amd64
  fi

  apt-get update
  apt-get install -y -f docker-engine

  is_loop_device=$(ls /dev/loop* &>/dev/null; echo $?)
  if [[ "$is_loop_device" != "0" ]]; then
    for i in {0..6}; do
      mknod -m0660 /dev/loop$i b 7 $i
    done
  fi
  echo "${DOCKER_VERSION}" >/root/.versions/docker
}

DOCKER_VERSION="$(uname -s)-$(uname -m)"
grep -q "^${DOCKER_COMPOSE_VERSION}" /root/.versions/docker-compose &>/dev/null || {
  echo "--> install docker-compose v${DOCKER_COMPOSE_VERSION}..."
    curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-${DOCKER_VERSION}" \
  > /usr/local/bin/docker-compose
  chmod 755 /usr/local/bin/docker-compose
  echo "${DOCKER_COMPOSE_VERSION}" > /root/.versions/docker-compose
}
