#!/bin/bash

############################## Docker installation ##############################
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get -y install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \ $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

# Install the latest version
sudo apt-get -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin


############################## GNS3 installation ################################
sudo apt-get update

sudo apt-get -y install python3 python3-pip pipx python3-pyqt5 python3-pyqt5.qtwebsockets python3-pyqt5.qtsvg qemu-kvm qemu-utils libvirt-clients libvirt-daemon-system virtinst software-properties-common ca-certificates curl gnupg2 

wget http://ftp.fr.debian.org/debian/pool/non-free/d/dynamips/dynamips_0.2.14-1_amd64.deb
sudo dpkg -i dynamips_0.2.14-1_amd64.deb
rm -rf ./dynamips_0.2.14-1_amd64.deb 

pipx ensurepath
pipx install gns3-server
pipx install gns3-gui

pipx inject gns3-gui gns3-server PyQt5
