#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

CUSER=${CUSER:-'root'}
LACAPITAINE_ICON_THEME_VERSION=${LACAPITAINE_ICON_THEME_VERSION:-'0.3.0'}

export DEBIAN_FRONTEND=noninteractive

# Ensure version directory exists
mkdir -p /root/.versions

# Ensure curl is installed
hash curl &>/dev/null || apt-get install -y curl

if [[ ${CUSER} == 'root' ]]; then
  user_home='/root'
else
  user_home="/home/${CUSER}"
fi

if [[ ! -d "${user_home}/.local/share/themes/axe rounded" ]]; then
  echo "--> install xfce axe theme..."
  curl -L https://dl.opendesktop.org/api/files/download/id/1460767141/73291-axe.tar.gz -o /tmp/xfce-axe.tar.gz
  mkdir -p "${user_home}/.local/share/themes"
  pushd "/tmp" &>/dev/null
    tar xvfz xfce-axe.tar.gz
    mv axe\ rounded "${user_home}/.local/share/themes/"
    chown -R "${CUSER}." "${user_home}/.local"
  popd &>/dev/null
fi

grep -q "^${LACAPITAINE_ICON_THEME_VERSION}" /root/.versions/lacapitaine &>/dev/null || {
  if [[ ! -d "${user_home}/.icons/la-capitaine-icon-theme-${LACAPITAINE_ICON_THEME_VERSION}" ]]; then
    echo "--> install icons theme lacapitaine v${LACAPITAINE_ICON_THEME_VERSION}..."
    curl -L "https://dl.opendesktop.org/api/files/download/id/1472166359/la-capitaine-icon-theme-${LACAPITAINE_ICON_THEME_VERSION}.tar.gz" \
      -o "/tmp/lacapitaine-icon-theme-${LACAPITAINE_ICON_THEME_VERSION}.tar.gz"
    mkdir -p "${user_home}/.icons"
    pushd "/tmp" &>/dev/null
      tar xvfz "lacapitaine-icon-theme-${LACAPITAINE_ICON_THEME_VERSION}.tar.gz"
      mv "la-capitaine-icon-theme-${LACAPITAINE_ICON_THEME_VERSION}" "${user_home}/.icons/la-capitaine-icon-theme-${LACAPITAINE_ICON_THEME_VERSION}"
      chown -R "${CUSER}." "${user_home}/.icons"
    popd &>/dev/null
    echo "${LACAPITAINE_ICON_THEME_VERSION}" >/root/.versions/lacapitaine
  fi
}
