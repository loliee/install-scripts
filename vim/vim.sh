#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

VIM_VERSION=${VIM_VERSION:-'8.0.0022'}

export DEBIAN_FRONTEND=noninteractive

# Ensure version directory exists
mkdir -p /root/.versions

# Ensure curl is installed
hash curl &>/dev/null || apt-get install -y curl

# Ensure make and compilator are installed
hash make &>/dev/null || apt-get install -y build-essential

# Ensure dependencies are installed
apt-get install -y libncurses5-dev

grep -q "^${VIM_VERSION}" /root/.versions/vim &>/dev/null || {
  apt-get purge -f -y vim vim-runtime gvim || true
  echo "--> install vim v${VIM_VERSION}..."
  if [[ ! -f "/tmp/vim-${VIM_VERSION}.tar.gz" ]]; then
    curl -o "/tmp/vim-${VIM_VERSION}.tar.gz" \
      -L "https://github.com/vim/vim/archive/v${VIM_VERSION}.tar.gz"
  fi
  pushd "/tmp/" &>/dev/null
    tar xvfz "/tmp/vim-${VIM_VERSION}.tar.gz"
    rm -rf /usr/local/src/vim &>/dev/null
    mv "vim-${VIM_VERSION}" /usr/local/src/vim
    pushd "/usr/local/src/vim" &>/dev/null
      ./configure \
        --enable-multibyte \
        --prefix=/usr/local \
        --with-features=huge \
        --enable-pythoninterp \
        --enable-python3interp \
        --enable-luainterp \
        --enable-rubyinterp
      make install
      echo "${VIM_VERSION}" > /root/.versions/vim
    popd &>/dev/null
  popd &>/dev/null
}
