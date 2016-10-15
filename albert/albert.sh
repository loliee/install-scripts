#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

ALBERT_VERSION=${ALBERT_VERSION:-'v0.8.11'}

export DEBIAN_FRONTEND=noninteractive

# Ensure version directory exists
mkdir -p /root/.versions

# Ensure git is installed
hash git &>/dev/null || apt-get install -y git

# Ensure make and compilator are installed
hash make &>/dev/null || apt-get install -y build-essential

# Ensure dependencies are installed
apt-get install -y \
                cmake \
                qtbase5-dev \
                libqt5x11extras5-dev \
                libqt5svg5-dev \
                libmuparser-dev

grep -q "^${ALBERT_VERSION}" /root/.versions/albert &>/dev/null || {
  if [[ ! -d /usr/local/src/albert ]]; then
  git clone https://github.com/ManuelSchneid3r/albert.git \
    /usr/local/src/albert
  fi
  pushd "/usr/local/src/albert" &>/dev/null
    git checkout "$ALBERT_VERSION"
    cmake . -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release
    make
    make install
  popd &>/dev/null
  echo "${ALBERT_VERSION}" >/root/.versions/albert
}
