#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

NETATALK_VERSION=${NETATALK_VERSION:-'3.1.11'}

echo "Prepare netatalk ${NETATALK_VERSION} release ..."
grep -q "^${NETATALK_VERSION}" /root/.versions/netatalk 2>/dev/null || {
  if [[ ! -f "netatalk-${NETATALK_VERSION}.tar.gz" ]]; then
    curl -o "netatalk-${NETATALK_VERSION}.tar.gz" \
      "https://freefr.dl.sourceforge.net/project/netatalk/netatalk/${NETATALK_VERSION}/netatalk-${NETATALK_VERSION}.tar.gz"
  fi

  set -x \
    && export DEBIAN_FRONTEND=noninteractive \
    && apt-get update \
    && sudo apt-get install -y \
      build-essential \
      libevent-dev \
      libssl-dev \
      libgcrypt-dev \
      libkrb5-dev \
      libpam0g-dev \
      libwrap0-dev \
      libdb-dev \
      libtdb-dev \
      libmariadbclient-dev \
      gstreamer1.0-plugins-base \
      avahi-daemon \
      libavahi-client-dev \
      libacl1-dev \
      libldap2-dev \
      libcrack2-dev \
      systemtap-sdt-dev \
      libdbus-1-dev \
      libdbus-glib-1-dev \
      libglib2.0-dev \
      libio-socket-inet6-perl \
      tracker \
      libtracker-sparql-1.0-dev \
      libtracker-miner-1.0-dev

  if [[ ! -d "netatalk-${NETATALK_VERSION}" ]]; then
    tar xvfz "netatalk-${NETATALK_VERSION}.tar.gz"
    pushd "netatalk-${NETATALK_VERSION}" &>/dev/null
      echo "--> install netatalk ..."
      ./configure \
          --with-init-style=debian-systemd \
          --without-libevent \
          --without-tdb \
          --with-cracklib \
          --enable-krbV-uam \
          --with-pam-confdir=/etc/pam.d \
          --with-dbus-daemon=/usr/bin/dbus-daemon \
          --with-dbus-sysconf-dir=/etc/dbus-1/system.d \
          --with-tracker-pkgconfig-version=1.0
      make
      make install

      systemctl enable avahi-daemon
      systemctl enable netatalk
      systemctl start avahi-daemon
      systemctl start netatalk
    popd &>/dev/null
  fi
}
