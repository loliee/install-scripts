#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

FZF_VERSION=${FZF_VERSION:-'0.15.4'}

export DEBIAN_FRONTEND=noninteractive

# Ensure version directory exists
mkdir -p /root/.versions

# Ensure curl is installed
hash git &>/dev/null || apt-get install -y git

# Ensure go is installed
hash golang &>/dev/null || apt-get install -y golang

# Ensure gcc is installed
hash gcc &>/dev/null || apt-get install -y build-essential

# Ensure dependencies are installed
apt-get install -y libncurses5-dev

grep -q "^${FZF_VERSION}" /root/.versions/fzf 2>/dev/null || {
  if [[ ! -d /usr/local/src/fzf ]]; then
    git clone https://github.com/junegunn/fzf.git /usr/local/src/fzf
  fi
  pushd "/usr/local/src/fzf" &>/dev/null
    git checkout "$FZF_VERSION"
    ./install --no-completion --key-bindings --no-update-rc
    ln -sf /usr/local/src/fzf/bin/fzf /usr/local/bin/fzf
    ln -sf /usr/local/src/fzf/bin/fzf-tmux /usr/local/bin/fzf-tmux
  popd &>/dev/null
  echo "${FZF_VERSION}" > /root/.versions/fzf
}
