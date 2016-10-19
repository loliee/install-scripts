#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

export DEBIAN_FRONTEND=noninteractive

apt-get purge -f -y \
  openjdk-7-jre \
  gcj-4.7-base \
  gcj-4.7-jre \
  openjdk-6-jre-headless || true

if [[ ! -f /etc/apt/sources.list.d/webupd8team-java.list ]]; then
  echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu xenial main" | \
    tee /etc/apt/sources.list.d/webupd8team-java.list
  echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu xenial main" | \
    tee -a /etc/apt/sources.list.d/webupd8team-java.list
  apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys EEA14886
fi

# Accept ORACLE license
echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections
echo debconf shared/accepted-oracle-license-v1-1 seen true | debconf-set-selections

apt-get update && apt-get install -y oracle-java8-installer
