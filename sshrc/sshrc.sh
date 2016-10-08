#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

export DEBIAN_FRONTEND=noninteractive

# Ensure curl is installed
hash curl &>/dev/null || apt-get install -y curl

curl -o /usr/local/bin/sshrc -L \
  https://raw.githubusercontent.com/Russell91/sshrc/master/sshrc
chmod +x /usr/local/bin/sshrc
