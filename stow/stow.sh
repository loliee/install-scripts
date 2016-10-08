#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

STOW_VERSION=${STOW_VERSION:-'2.2.2'}

export DEBIAN_FRONTEND=noninteractive

# Ensure version directory exists
mkdir -p /root/.versions

# Ensure curl is installed
hash curl &>/dev/null || apt-get install -y curl

# Ensure gcc is installed
hash gcc &>/dev/null || apt-get install -y build-essential

grep -q "^${STOW_VERSION}" /root/.versions/stow &>/dev/null || {
  echo "--> install stow v${STOW_VERSION}..."
  apt-get purge -f -y stow || true
  if [[ ! -f "/tmp/stow-${STOW_VERSION}.tar.gz" ]]; then
    curl -L -o "/tmp/stow-${STOW_VERSION}.tar.gz" \
      "http://ftp.gnu.org/gnu/stow/stow-${STOW_VERSION}.tar.gz"
  fi
  pushd "/tmp/" &>/dev/null
    tar xvfz "/tmp/stow-${STOW_VERSION}.tar.gz"
    rm -rf /usr/local/src/stow &>/dev/null
    mv "stow-${STOW_VERSION}" /usr/local/src/stow
    pushd "/usr/local/src/stow" &>/dev/null
      ./configure
      make install
      echo "${STOW_VERSION}" > /root/.versions/stow
    popd &>/dev/null
  popd &>/dev/null
}
