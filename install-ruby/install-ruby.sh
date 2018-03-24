#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

CUSER=${CUSER:-'root'}
CHRUBY_VERSION=${CHRUBY_VERSION:-'0.3.9'}
GEM_LIST=${GEM_LIST:-}
RUBY_VERSION=${RUBY_VERSION:-'2.3.1'}
INSTALL_RUBY_VERSION=${INSTALL_RUBY_VERSION:-'0.6.0'}
RUBIES=(
 "$RUBY_VERSION"
)

export DEBIAN_FRONTEND=noninteractive

export PATH=/usr/local/src/ruby-${RUBY_VERSION}/bin/:$PATH

# Ensure version directory exists
mkdir -p /root/.versions

# Ensure curl is installed
hash curl &>/dev/null || apt-get install -y curl

# Ensure make and compilator are installed
hash make &>/dev/null || apt-get install -y build-essential

curl -L -o "postmodern.asc" \
            https://raw.github.com/postmodern/postmodern.github.io/master/postmodern.asc
gpg --import postmodern.asc

grep -q "^${CHRUBY_VERSION}" /root/.versions/chruby &>/dev/null || {
  echo "--> install chruby v${CHRUBY_VERSION}..."
  if [[ ! -f "/tmp/chruby-${CHRUBY_VERSION}.tar.gz" ]]; then
    curl -L -o "/tmp/chruby-${CHRUBY_VERSION}.tar.gz" \
      "https://github.com/postmodern/chruby/archive/v${CHRUBY_VERSION}.tar.gz"
    curl -L -o "/tmp/chruby-${CHRUBY_VERSION}.tar.gz.asc" \
      "https://raw.github.com/postmodern/chruby/master/pkg/chruby-${CHRUBY_VERSION}.tar.gz.asc"
  fi
  pushd "/tmp/" &>/dev/null
    #gpg --verify "chruby-${CHRUBY_VERSION}.tar.gz.asc" "chruby-${CHRUBY_VERSION}.tar.gz"
    tar xvfz "/tmp/chruby-${CHRUBY_VERSION}.tar.gz"
    pushd "chruby-${CHRUBY_VERSION}" &>/dev/null
      ./scripts/setup.sh
    popd &>/dev/null
  popd &>/dev/null
  echo "${CHRUBY_VERSION}" >/root/.versions/chruby
}

# shellcheck disable=SC2206
grep -q "^${INSTALL_RUBY_VERSION}" /root/.versions/install-ruby &>/dev/null || {
  echo "--> install install-ruby v${INSTALL_RUBY_VERSION}..."
  if [[ ! -f "/tmp/install-ruby-${INSTALL_RUBY_VERSION}.tar.gz" ]]; then
    curl -L -o "/tmp/install-ruby-${INSTALL_RUBY_VERSION}.tar.gz" \
      "https://github.com/postmodern/ruby-install/archive/v${INSTALL_RUBY_VERSION}.tar.gz"
    curl -L -o "/tmp/install-ruby-${INSTALL_RUBY_VERSION}.tar.gz.asc" \
      "https://raw.github.com/postmodern/ruby-install/master/pkg/ruby-install-${INSTALL_RUBY_VERSION}.tar.gz.asc"
  fi
  pushd "/tmp/" &>/dev/null
    #gpg --verify "ruby-install-${INSTALL_RUBY_VERSION}.tar.gz.asc" "ruby-install-${INSTALL_RUBY_VERSION}.tar.gz"
    tar xvfz "/tmp/install-ruby-${INSTALL_RUBY_VERSION}.tar.gz"
    rm -rf /usr/local/src/install-ruby &>/dev/null
    mv "ruby-install-${INSTALL_RUBY_VERSION}" /usr/local/src/install-ruby
    pushd "/usr/local/src/install-ruby" &>/dev/null
      make install
      mkdir -p ~/.rubies
      RUBIES=(
        $RUBY_VERSION
      )
      if [[ ${CUSER} == 'root' ]]; then
        user_home='/root'
      else
        user_home="/home/${CUSER}"
      fi
      for ruby in "${RUBIES[@]}"; do
        ruby-install --no-reinstall --rubies-dir "${user_home}/.rubies" \
        ruby "$ruby"
      done
      echo "${RUBIES[@]:(-1)}" > "${user_home}/.ruby-version"
      echo "${INSTALL_RUBY_VERSION}" >/root/.versions/install-ruby
    popd &>/dev/null
  popd &>/dev/null
}

# shellcheck disable=SC2206
if [[ ! -z $GEM_LIST ]]; then
  gem_list_array=(${GEM_LIST//,/ })
  for i in "${!gem_list_array[@]}"; do
    gem install "${gem_list_array[i]}"
  done
fi
