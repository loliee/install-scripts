#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

FLANNEL_VERSION=${FLANNEL_VERSION:-"0.6.2"}

export DEBIAN_FRONTEND=noninteractive

# Ensure version directory exists
mkdir -p /root/.versions

# Ensure curl is installed
hash curl &>/dev/null || apt-get install -y curl

if [ -f "/etc/debian_version" ]; then
  apt-get install -y upstart
fi

echo "Prepare flannel ${FLANNEL_VERSION} release ..."
grep -q "^${FLANNEL_VERSION}\$" /root/.versions/flannel 2>/dev/null || {
  curl -L -o flannel.tar.gz \
    "https://github.com/coreos/flannel/releases/download/v${FLANNEL_VERSION}/flannel-v${FLANNEL_VERSION}-linux-amd64.tar.gz"
  mkdir -p "flannel-v${FLANNEL_VERSION}-linux-amd64/flanneld"
  tar xzf flannel.tar.gz -C  "flannel-v${FLANNEL_VERSION}-linux-amd64" && rm -rf flannel.tar.gz
  cp "flannel-v${FLANNEL_VERSION}-linux-amd64/flanneld" /usr/local/bin/
  rm -rf "flannel-v${FLANNEL_VERSION}-linux-amd64"
  echo "${FLANNEL_VERSION}" > /root/.versions/flannel
}

if [[ ! -f /etc/init/flanneld.conf ]]; then
  cat <<EOT >> "/etc/init/flanneld.conf"
description "Flannel service"
author "@loliee"

respawn

start on started etcd
stop on stopping etcd

limit nofile 65536 65536

pre-start script
        FLANNEL=/usr/local/bin/\$UPSTART_JOB
        if [ -f /etc/default/\$UPSTART_JOB ]; then
                . /etc/default/\$UPSTART_JOB
        fi
        if [ -f \$FLANNEL ]; then
                exit 0
        fi
    exit 22
end script

script
        FLANNEL=/usr/local/bin/\$UPSTART_JOB
        FLANNEL_OPTS=""
        if [ -f /etc/default/\$UPSTART_JOB ]; then
                . /etc/default/\$UPSTART_JOB
        fi
        exec "\$FLANNEL" \$FLANNEL_OPTS
end script
EOT
fi

if [[ ! -f /etc/default/flanneld ]]; then
  cat <<EOT >> "/etc/default/flanneld"
FLANNEL_OPTS=""
EOT
fi
