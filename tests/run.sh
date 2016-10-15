#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

LIMIT=${LIMIT:-''}
DISTRIB=${DISTRIB-'debian:jessie'}

export SPEC_OPTS='--format documentation --color'

for file in ./*/*.sh; do
  if [[ "$file" == **"${LIMIT}"** ]] && [[ "$file" != **"/tests/"** ]]; then
    echo "$file"
    appname="$(echo "$file" | awk '{split($0,a,"/"); print a[2]}')"
    container_name=${DISTRIB/:/-}-${appname}
    export appname \
         container_name

    echo "--> Run docker ${container_name}"
    docker run -d --name "${container_name}" -v "${PWD}:/scripts" "${DISTRIB}" tail -f /dev/null
    docker exec "${container_name}" apt-get update
    docker exec "${container_name}" "/scripts/${appname}/${appname}.sh"
    rake serverspec:run
    docker rm -f "${container_name}"
  fi
done
