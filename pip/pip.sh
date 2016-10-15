#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

# Ensure curl is installed
hash curl &>/dev/null || apt-get install -y curl

# Ensure python is installed
hash python &>/dev/null || apt-get install -y python

echo "--> install pip..."
hash pip &>/dev/null || {
  curl -o /tmp/get-pip.py -L "https://bootstrap.pypa.io/get-pip.py"
  python /tmp/get-pip.py
}
