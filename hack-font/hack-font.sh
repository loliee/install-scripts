#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

HACK_VERSION=${HACK_VERSION:-'2.020'}

export DEBIAN_FRONTEND=noninteractive

# Ensure version directory exists
mkdir -p /root/.versions

# Ensure curl is installed
hash curl &>/dev/null || apt-get install -y curl

# Ensure unzip is installed
hash unzip &>/dev/null || apt-get install -y unzip

grep -q "^${HACK_VERSION}" /root/.versions/hack-font &>/dev/null || {
  if [[ ! -f "/tmp/hack-${HACK_VERSION}-ttf.zip" ]]; then
  echo "--> install hack font v${HACK_VERSION}..."
    curl -o "/tmp/hack-${HACK_VERSION}-ttf.zip" \
      -L "https://github.com/chrissimpkins/Hack/releases/download/v${HACK_VERSION}/Hack-v${HACK_VERSION/./_}-ttf.zip"
  fi
  unzip -d /usr/share/fonts/ "/tmp/hack-${HACK_VERSION}-ttf.zip"
  ls /usr/share/fonts/
  echo "${HACK_VERSION}" > /root/.versions/hack-font
}
