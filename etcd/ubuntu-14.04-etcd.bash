#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

ETCD_VERSION=${ETCD_VERSION:-"2.3.7"}
ETCD="etcd-v${ETCD_VERSION}-linux-amd64"
echo "Prepare etcd ${ETCD_VERSION} release ..."
grep -q "^${ETCD_VERSION}" /root/.etcd 2>/dev/null || {
  curl -L -o etcd.tar.gz \
    "https://github.com/coreos/etcd/releases/download/v${ETCD_VERSION}/${ETCD}.tar.gz"
  tar xzf etcd.tar.gz && rm -f etcd.tar.gz
  cp "${ETCD}/etcd" "${ETCD}/etcdctl" /usr/local/bin/
  rm -rf "${ETCD}"
  echo "${ETCD_VERSION}" > /root/.etcd
}

if [[ ! -f /etc/init/etcd.conf ]]; then
  cat <<EOT >> "/etc/init/etcd.conf"
description "Etcd service"
author "@loliee"

start on (net-device-up
          and local-filesystems
          and runlevel [2345])

respawn

limit nofile 65536 65536

pre-start script
	ETCD=/usr/local/bin/\$UPSTART_JOB
	if [ -f /etc/default/\$UPSTART_JOB ]; then
		. /etc/default/\$UPSTART_JOB
	fi
	if [ -f \$ETCD ]; then
		exit 0
	fi
    echo "\$ETCD binary not found, exiting"
    exit 22
end script

script
	ETCD=/usr/local/bin/\$UPSTART_JOB
	ETCD_OPTS=""
	if [ -f /etc/default/\$UPSTART_JOB ]; then
		. /etc/default/\$UPSTART_JOB
	fi
	exec "\$ETCD" \$ETCD_OPTS
end script
EOT
fi

if [[ ! -f /etc/default/etcd ]]; then
cat <<EOT >> "/etc/default/etcd"
ETCD_OPTS=""
EOT
fi
