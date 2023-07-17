#!/bin/bash -e

sudo apt-get update; sudo apt-get install -y curl git ca-certificates gnupg

# Install Docker
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | \
  sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update; sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Install Jumppad
echo "deb [trusted=yes] https://apt.fury.io/jumppad/ /" | \
  sudo tee -a /etc/apt/sources.list.d/fury.list
sudo apt-get update; sudo apt-get install -y jumppad

# Run the Workshop
git clone https://github.com/jumppad-labs/terraform-workshop.git

# Run jumppad to cache the images
pushd terraform-workshop
sudo jumppad up
sudo jumppad down

# move the workshop files
popd
sudo mv terraform-workshop /root/terraform-workshop
