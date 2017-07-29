#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

set -x \
  && export DEBIAN_FRONTEND=noninteractive \
  && apt-get update \
  && apt-get upgrade -y \
  && apt-get install -y \
    automake \
    bc \
    bzip2 \
    erlang-base \
    erlang-nox \
    git \
    htop \
    imagemagick \
    jq \
    iotop \
    lsof \
    libssl-dev \
    libyaml-dev \
    nmap \
    net-tools \
    python-dev \
    python-setuptools \
    python-picamera \
    python-virtualenv \
    rsync \
    socat \
    strace \
    supervisor \
    tcpdump \
    tmux \
    ufw \
    unzip \
    vim \
    vlc \
    zip \
    zsh

# Enable camera
#echo 'dtparam=audio=on' >> /boot/config.txt
echo 'start_x=1' >> /boot/config.txt
echo 'gpu_mem=128' >> /boot/config.txt

# Setup firewall
sudo ufw allow ssh
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw --force enable

# Configure Git repositories
GIT_DIR=/home/pi/git/s4turn1.git
mkdir -p "${GIT_DIR}"
pushd "${GIT_DIR}" &>/dev/null
  git init --bare
popd &>/dev/null

cat <<EOF > ${GIT_DIR}/hooks/post-receive
#!/bin/bash
# Deploy s4turn1 server

export DEPLOY_ROOT=/usr/local/src/s4turn1
export GIT_DIR="\$(cd \$(dirname \$(dirname \$0));pwd)"
export GIT_WORK_TREE="\${DEPLOY_ROOT}"

echo "Deploy s4turn1 on '\$(hostname -f)'"

mkdir -p "\${DEPLOY_ROOT}"

while read oldrev newrev refname
do

    export DEPLOY_BRANCH=\$(git rev-parse --symbolic --abbrev-ref \$refname)
    export DEPLOY_OLDREV="\$oldrev"
    export DEPLOY_NEWREV="\$newrev"
    export DEPLOY_REFNAME="\$refname"

    if [ "\$DEPLOY_NEWREV" = "0000000000000000000000000000000000000000" ]; then
        echo "This ref has been deleted"
        exit 1
    fi

    git checkout -f "\${DEPLOY_BRANCH}" || exit 1
    git reset --hard "\$DEPLOY_NEWREV" || exit 1
    pushd "\${DEPLOY_ROOT}"
        sudo make install
        sudo supervisorctl reread
        sudo supervisorctl restart all
    popd

done
exit 0
EOF

# Disable rsyslog message https://blog.dantup.com/2016/04/removing-rsyslog-spam-on-raspberry-pi-raspbian-jessie/
sudo sed -i '/# The named pipe \/dev\/xconsole/,$d' /etc/rsyslog.conf

git clone "${GIT_DIR}" /usr/local/src/s4turn1

chown -R pi:pi "${GIT_DIR}"
chown -R pi:pi /usr/local/src/s4turn1
chmod 755 "$GIT_DIR/hooks/post-receive"
