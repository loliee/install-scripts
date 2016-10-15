#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

BATS_VERSION=${BATS_VERSION:-'0.4.0'}

export DEBIAN_FRONTEND=noninteractive

# Ensure version directory exists
mkdir -p /root/.versions

# Ensure curl is installed
hash git &>/dev/null || apt-get install -y git

grep -q "^${BATS_VERSION}" /root/.versions/bats &>/dev/null || {
  echo "--> install bats v${BATS_VERSION}..."
  if [[ ! -d /tmp/bats ]]; then
    git clone https://github.com/sstephenson/bats.git /tmp/bats
  fi
  pushd "/tmp/bats" &>/dev/null
      git checkout "v${BATS_VERSION}"
      ./install.sh /usr/local
      echo "${BATS_VERSION}" > /root/.versions/bats
  popd &>/dev/null
}
