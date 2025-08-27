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

############################## vpcs installation ################################
wget https://github.com/GNS3/vpcs/archive/refs/tags/v0.8.3.tar.gz
tar xzf v0.8.3.tar.gz 
cd vpcs-0.8.3/src
bash mk.sh 
sudo mv vpcs /usr/bin/
sudo chown root:root /usr/bin/vpcs 
cd ../..
rm -rf v0.8.3.tar.gz vpcs-0.8.3

############################## ubridge installation #############################
sudo apt install -y cmake make g++ libpcap-dev libelf-dev libcap-dev
git clone https://github.com/GNS3/ubridge.git
cd ubridge
make
sudo make install
cd ..
rm -rf ubridge

############################## JWT secret key installation ######################
JWT_SECRET_KEY=$(openssl rand -hex 32)
echo -e "[auth]\njwt_secret_key = $JWT_SECRET_KEY" > $HOME/.config/GNS3/3.0/gns3_server.conf

pipx ensurepath
pipx install gns3-server
pipx install gns3-gui

pipx inject gns3-gui gns3-server PyQt5
