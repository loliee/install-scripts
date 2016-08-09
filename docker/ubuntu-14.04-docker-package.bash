#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

DOCKER_VERSION='1.12.0'

echo "Prepare docker ${DOCKER_VERSION} release ..."
apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
echo 'deb https://apt.dockerproject.org/repo ubuntu-trusty main' > /etc/apt/sources.list.d/docker.list
apt-get update
apt-get install -y apt-transport-https ca-certificates
apt-get purge lxc-docker || true
apt-get install -y docker-engine git

is_loop_device=$(ls /dev/loop* &>/dev/null; echo $?)
if [[ "$is_loop_device" != "0" ]]; then
  for i in {0..6}; do
      mknod -m0660 /dev/loop$i b 7 $i
  done
fi

# Fix issue on ubuntu trusty
# https://github.com/docker/docker/issues/20221
rm -rf /var/lib/docker/devicemapper
rm -rf /var/lib/docker/network
