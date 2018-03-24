#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

DOCKER_VERSION=${DOCKER_VERSION:-'17.07.0-ce'}
DOCKER_COMPOSE_VERSION=${DOCKER_COMPOSE_VERSION:-'1.16.1'}

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
  if [[ "$(lsb_release -c --short)" == 'trusty' ]]; then
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

    # shellcheck disable=SC1091
    if [[ ! -f /etc/apt/sources.list.d/docker.list ]]; then
      curl -fsSL "https://download.docker.com/linux/$(. /etc/os-release; echo "$ID")/gpg" | sudo apt-key add -
      sudo add-apt-repository \
           "deb [arch=amd64] https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") \
              $(lsb_release -cs) \
                 stable"
    fi
    apt-get install -y linux-headers-amd64
  fi

  apt-get update
  apt-get install -y docker-ce
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
