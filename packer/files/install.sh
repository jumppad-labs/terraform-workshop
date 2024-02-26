#!/bin/bash
set -e

export DEBIAN_FRONTEND=noninteractive

echo "waiting 180 seconds for cloud-init to update /etc/apt/sources.list"
timeout 180 /bin/bash -c \
  'until stat /var/lib/cloud/instance/boot-finished 2>/dev/null; do echo waiting ...; sleep 1; done'

apt-get update && apt-get -y upgrade
apt-get -y install \
    apt-transport-https \
    ca-certificates \
    software-properties-common \
    sudo \
    unzip \
    git \
    curl \
    jq \
    vim

# Install Docker
curl -fsSL https://download.docker.com/linux/$(. /etc/os-release; echo "$ID")/gpg | sudo apt-key add -
add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") \
   $(lsb_release -cs) \
   stable"

apt-get update && apt-get install -y docker-ce

# Install Jumppad
curl -s -L https://github.com/jumppad-labs/jumppad/releases/download/${JUMPPAD_VERSION}/jumppad_${JUMPPAD_VERSION}_linux_x86_64.tar.gz | tar -xz
mv jumppad /usr/local/bin/jumppad
chmod +x /usr/local/bin/jumppad

cp /tmp/resources/jumppad-connector.service /etc/systemd/system/jumppad-connector.service

systemctl daemon-reload
systemctl enable jumppad-connector.service

# Pre-pull docker images
for IMAGE in $JUMPPAD_IMAGES; do
  docker pull $IMAGE
done  