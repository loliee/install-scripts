#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

FASD_VERSION=${FASD_VERSION:-'1.0.1'}

# Ensure version directory exists
mkdir -p /root/.versions

# Ensure curl is installed
hash git &>/dev/null || apt-get install -y git

# Ensure make and compilator are installed
hash make &>/dev/null || apt-get install -y build-essential

echo "Prepare fasd ${FASD_VERSION} release ..."
grep -q "^${FASD_VERSION}" /root/.versions/fasd 2>/dev/null || {
  if [[ ! -d /usr/local/src/fasd ]]; then
    echo "--> install fasd ..."
    git clone https://github.com/clvv/fasd.git /usr/local/src/fasd
  fi
  pushd "/usr/local/src/fasd" &>/dev/null
    git checkout "$FASD_VERSION"
    make install
  popd &>/dev/null
  echo "${FASD_VERSION}" > /root/.versions/fasd
}
