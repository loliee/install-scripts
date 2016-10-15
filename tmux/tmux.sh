#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

TMUX_VERSION=${TMUX_VERSION:-'2.3'}

# Ensure version directory exists
mkdir -p /root/.versions

# Ensure curl is installed
hash curl &>/dev/null || apt-get install -y curl

# Ensure dependencies are installed
apt-get install -y libevent-dev \
                   libncurses5-dev

# Ensure build-essential is installed
hash gcc &>/dev/null || apt-get install -y build-essential
hash make &>/dev/null || apt-get install -y build-essential

grep -q "^${TMUX_VERSION}" /root/.versions/tmux &>/dev/null || {
  apt-get purge -f -y tmux || true
  echo "--> install tmux v${TMUX_VERSION}..."
  if [[ ! -f "/tmp/tmux-${TMUX_VERSION}.tar.gz" ]]; then
    curl -L -o "/tmp/tmux-${TMUX_VERSION}.tar.gz" \
      "https://github.com/tmux/tmux/releases/download/${TMUX_VERSION}/tmux-${TMUX_VERSION}.tar.gz"
  fi
  pushd "/tmp/" &>/dev/null
    tar xvfz "tmux-${TMUX_VERSION}.tar.gz"
    rm -rf /usr/local/src/tmux &>/dev/null || true
    mv "tmux-${TMUX_VERSION}" /usr/local/src/tmux
    pushd "/usr/local/src/tmux" &>/dev/null
      ./configure && make
      make install
      echo "${TMUX_VERSION}" > /root/.versions/tmux
    popd &>/dev/null
  popd &>/dev/null
}
