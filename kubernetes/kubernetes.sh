#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

export DEBIAN_FRONTEND=noninteractive

echo "Install kubeadm and kubernetes tooling..."
apt-get update && apt-get install -y apt-transport-https
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF

apt-get update
apt-get install -y kubelet kubeadm kubectl
