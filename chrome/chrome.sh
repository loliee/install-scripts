#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

export DEBIAN_FRONTEND=noninteractive

# Chrome
if [[ ! -f /etc/apt/sources.list.d/google-chrome.list ]]; then
  echo 'deb http://dl.google.com/linux/chrome/deb/ stable main' > /etc/apt/sources.list.d/google-chrome.list
  apt-key adv --keyserver keyserver.ubuntu.com --recv-keys A040830F7FAC5991
fi

apt-get update && apt-get install -y google-chrome-stable
