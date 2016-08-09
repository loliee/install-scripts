#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

FLANNEL_VERSION=${FLANNEL_VERSION:-"0.5.5"}
echo "Prepare flannel ${FLANNEL_VERSION} release ..."
grep -q "^${FLANNEL_VERSION}\$" /root/.flannel 2>/dev/null || {
  curl -L -o flannel.tar.gz \
    "https://github.com/coreos/flannel/releases/download/v${FLANNEL_VERSION}/flannel-${FLANNEL_VERSION}-linux-amd64.tar.gz"
  tar xzf flannel.tar.gz && rm -rf flannel.tar.gz
  cp "flannel-${FLANNEL_VERSION}/flanneld" /usr/local/bin/
  rm -rf "flannel-${FLANNEL_VERSION}"
  echo "${FLANNEL_VERSION}" > /root/.flannel
}

if [[ ! -f /etc/init/flanneld.conf ]]; then
  cat <<EOT >> "/etc/init/flanneld.conf"
description "Flannel service"
author "@chenxingyu"

respawn

# start in conjunction with etcd
start on started etcd
stop on stopping etcd

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
        # modify these in /etc/default/\$UPSTART_JOB (/etc/default/docker)
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
  cat <<EOT >> "/etc/default/flanned"
FLANNEL_OPTS=""
EOT
fi

initctl reload-configuration
