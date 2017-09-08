#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

export DEBIAN_FRONTEND=noninteractive
ZFS_IMPORT_ALL=${ZFS_IMPORT_ALL:-}

if lsb_release -a | grep stretch; then

  apt-add-repository -s 'deb  http://deb.debian.org/debian stretch contrib non-free'

  set -x \
    && export DEBIAN_FRONTEND=noninteractive \
    && apt-get update \
    && apt-get install -y \
      spl-dkms \
      zfs-dkms

  if [[ ! -z $ZFS_IMPORT_ALL ]]; then
    zpool import -a
  fi
fi
