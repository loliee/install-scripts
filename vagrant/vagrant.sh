#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

VAGRANT_VERSION=${VAGRANT_VERSION:-'1.8.5'}

export DEBIAN_FRONTEND=noninteractive

# Ensure version directory exists
mkdir -p /root/.versions

# Ensure curl is installed
hash curl &>/dev/null || apt-get install -y curl

echo "Prepare vagrant ${VAGRANT_VERSION} release ..."
grep -q "^${VAGRANT_VERSION}" /root/.versions/vagrant 2>/dev/null || {
  if [[ ! -f "/tmp/vagrant-${VAGRANT_VERSION}.deb" ]]; then
    curl -o "/tmp/vagrant-${VAGRANT_VERSION}.deb" \
    "https://releases.hashicorp.com/vagrant/${VAGRANT_VERSION}/vagrant_${VAGRANT_VERSION}_x86_64.deb"
  fi
  dpkg -i "/tmp/vagrant-${VAGRANT_VERSION}.deb"
  echo "${VAGRANT_VERSION}" > /root/.versions/vagrant
}
