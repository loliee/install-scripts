#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

export KUBE_VERSION=${KUBE_VERSION:-}

# Then the role variable defines the role of above machine in the same order, “ai” stands for machine acts as both master
# and node, “a” stands for master, “i” stands for node.
export KUBE_ROLE=${KUBE_ROLE:-'ai'}

function get_latest_version_number {
  local -r latest_url="https://storage.googleapis.com/kubernetes-release/release/stable.txt"
  if [[ $(which wget) ]]; then
    wget -qO- ${latest_url}
  elif [[ $(which curl) ]]; then
    curl -Ss ${latest_url}
  else
    echo "Couldn't find curl or wget.  Bailing out." >&2
    exit 4
  fi
}

if [[ -z "$KUBE_VERSION" ]]; then
  KUBE_VERSION=$(get_latest_version_number | sed 's/^v//')
fi

echo "Prepare kubernetes ${KUBE_VERSION} release ..."
grep -q "^${KUBE_VERSION}\$" /root/.kubernetes 2>/dev/null || {
  mkdir -p /etc/kubernetes/manifests
  curl -L -o kubernetes.tar.gz \
    "https://github.com/kubernetes/kubernetes/releases/download/v${KUBE_VERSION}/kubernetes.tar.gz"
  tar xzf kubernetes.tar.gz && rm -f kubernetes.tar.gz
  pushd kubernetes/server
  tar xzf kubernetes-server-linux-amd64.tar.gz && rm -f kubernetes-server-linux-amd64.tar.gz
  popd

  if [[ "${KUBE_ROLE}" == *"a"* ]]; then
    cp kubernetes/server/kubernetes/server/bin/kube-apiserver \
       kubernetes/server/kubernetes/server/bin/kube-controller-manager \
       kubernetes/server/kubernetes/server/bin/kube-scheduler \
       kubernetes/server/kubernetes/server/bin/kubectl /usr/local/bin/
  fi

  if [[ "${KUBE_ROLE}" == *"i"* ]]; then
    cp kubernetes/server/kubernetes/server/bin/kubelet \
       kubernetes/server/kubernetes/server/bin/kube-proxy /usr/local/bin/
  fi
  rm -rf kubernetes
  echo "${KUBE_VERSION}" > /root/.kubernetes
}

# Master - Api server
if [[ ! -f /etc/init/kube-apiserver.conf ]]; then
  cat <<EOT >> "/etc/init/kube-apiserver.conf"
description "Kube-Apiserver service"
author "@loliee"

respawn

start on started etcd
stop on stopping etcd

limit nofile 65536 65536

pre-start script
	KUBE_APISERVER=/usr/local/bin/\$UPSTART_JOB
	if [ -f /etc/default/\$UPSTART_JOB ]; then
		. /etc/default/\$UPSTART_JOB
	fi
	if [ -f \$KUBE_APISERVER ]; then
		exit 0
	fi
    exit 22
end script

script
	KUBE_APISERVER=/usr/local/bin/\$UPSTART_JOB
	KUBE_APISERVER_OPTS=""
	if [ -f /etc/default/\$UPSTART_JOB ]; then
		. /etc/default/\$UPSTART_JOB
	fi
	exec "\$KUBE_APISERVER" \$KUBE_APISERVER_OPTS
end script
EOT
fi
if [[ ! -f /etc/default/kube-apiserver ]] && [[ "${KUBE_ROLE}" == *"a"* ]]; then
  cat <<EOT >> "/etc/default/kube-apiserver"
KUBE_APISERVER_OPTS=""
EOT
fi

# Master - Controller Manager
if [[ ! -f /etc/init/kube-controller-manager.conf ]]; then
  cat <<EOT >> "/etc/init/kube-controller-manager.conf"
description "Kube-Controller-Manager service"
author "@loliee"

respawn

start on started etcd
stop on stopping etcd

limit nofile 65536 65536

pre-start script
	KUBE_CONTROLLER_MANAGER=/usr/local/bin/\$UPSTART_JOB
	if [ -f /etc/default/\$UPSTART_JOB ]; then
		. /etc/default/\$UPSTART_JOB
	fi
	if [ -f \$KUBE_CONTROLLER_MANAGER ]; then
		exit 0
	fi
    exit 22
end script

script
	KUBE_CONTROLLER_MANAGER=/usr/local/bin/\$UPSTART_JOB
	KUBE_CONTROLLER_MANAGER_OPTS=""
	if [ -f /etc/default/\$UPSTART_JOB ]; then
		. /etc/default/\$UPSTART_JOB
	fi
	exec "\$KUBE_CONTROLLER_MANAGER" \$KUBE_CONTROLLER_MANAGER_OPTS
end script
EOT
fi
if [[ ! -f /etc/default/kube-controller-manager ]] && [[ "${KUBE_ROLE}" == *"a"* ]]; then
  cat <<EOT >> "/etc/default/kube-controller-manager"
KUBE_CONTROLLER_MANAGER_OPTS=""
EOT
fi

# Master - Scheduler
if [[ ! -f /etc/init/kube-scheduler.conf ]]; then
  cat <<EOT >> "/etc/init/kube-scheduler.conf"
description "Kube-Scheduler service"
author "@loliee"

respawn

start on started etcd
stop on stopping etcd

limit nofile 65536 65536

pre-start script
	KUBE_SCHEDULER=/usr/local/bin/\$UPSTART_JOB
	if [ -f /etc/default/\$UPSTART_JOB ]; then
		. /etc/default/\$UPSTART_JOB
	fi
	if [ -f \$KUBE_SCHEDULER ]; then
		exit 0
	fi
    exit 22
end script

script
	KUBE_SCHEDULER=/usr/local/bin/\$UPSTART_JOB
	KUBE_SCHEDULER_OPTS=""
	if [ -f /etc/default/\$UPSTART_JOB ]; then
		. /etc/default/\$UPSTART_JOB
	fi
	exec "\$KUBE_SCHEDULER" \$KUBE_SCHEDULER_OPTS
end script
EOT
fi
if [[ ! -f /etc/default/kube-scheduler ]] && [[ "${KUBE_ROLE}" == *"a"* ]]; then
  cat <<EOT >> "/etc/default/kube-scheduler"
KUBE_SCHEDULER_OPTS=""
EOT
fi

# Minion - Proxy
if [[ ! -f /etc/init/kube-proxy.conf ]]; then
  cat <<EOT >> "/etc/init/kube-proxy.conf"
description "Kube-Proxy service"
author "@loliee"

respawn

start on started flanneld
stop on stopping flanneld

limit nofile 65536 65536

pre-start script
	KUBE_PROXY=/usr/local/bin/\$UPSTART_JOB
	if [ -f /etc/default/\$UPSTART_JOB ]; then
		. /etc/default/\$UPSTART_JOB
	fi
	if [ -f \$KUBE_PROXY ]; then
		exit 0
	fi
    exit 22
end script

script
	KUBE_PROXY=/usr/local/bin/\$UPSTART_JOB
	KUBE_PROXY_OPTS=""
	if [ -f /etc/default/\$UPSTART_JOB ]; then
		. /etc/default/\$UPSTART_JOB
	fi
	exec "\$KUBE_PROXY" \$KUBE_PROXY_OPTS
end script
EOT
fi
if [[ ! -f /etc/default/kube-proxy ]] && [[ "${KUBE_ROLE}" == *"i"* ]]; then
  cat <<EOT >> "/etc/default/kube-proxy"
KUBE_PROXY_OPTS=""
EOT
fi

# Minion - Kubelet
if [[ ! -f /etc/init/kubelet.conf ]]; then
  cat <<EOT >> "/etc/init/kubelet.conf"
description "Kubelet service"
author "@loliee"

respawn

start on started flanneld
stop on stopping flanneld

limit nofile 65536 65536

pre-start script
	KUBELET=/usr/local/bin/\$UPSTART_JOB
	if [ -f /etc/default/\$UPSTART_JOB ]; then
		. /etc/default/\$UPSTART_JOB
	fi
	if [ -f \$KUBELET ]; then
		exit 0
	fi
    exit 22
end script

script
	KUBELET=/usr/local/bin/\$UPSTART_JOB
	KUBELET_OPTS=""
	if [ -f /etc/default/\$UPSTART_JOB ]; then
		. /etc/default/\$UPSTART_JOB
	fi
	exec "\$KUBELET" \$KUBELET_OPTS
end script
EOT
fi
if [[ ! -f /etc/default/kubelet ]] && [[ "${KUBE_ROLE}" == *"i"* ]]; then
  cat <<EOT >> "/etc/default/kubelet"
KUBELET_OPTS=""
EOT
fi
