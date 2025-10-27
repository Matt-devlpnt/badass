#!/bin/bash

DOCKER=$(docker ps -q)


# ip addr add 30.1.1.1/24 dev eth1
# Assigns the IP address 30.1.1.1 with a subnet mask of /24 (255.255.255.0) to the eth1 interface. This configures eth0 for communication on the 10.1.1.0/24 network

init_host1() {
	docker exec $1 ip addr add 30.1.1.1/24 dev eth1
}


# ip addr add 30.1.1.2/24 dev eth1
# Assigns the IP address 30.1.1.2 with a subnet mask of /24 (255.255.255.0) to the eth1 interface. This configures eth0 for communication on the 10.1.1.0/24 network

init_host2() {
	docker exec $1 ip addr add 30.1.1.2/24 dev eth1
}


# ip link add br0 type bridge
# Creates a network bridge device named br0. A bridge connects multiple network interfaces at the data link layer (Layer 2)

# ip link set dev br0 up
# Activates the bridge device br0, bringing it online

# ip addr add 10.1.1.1/24 dev eth0
# Assigns the IP address 10.1.1.1 with a subnet mask of /24 (255.255.255.0) to the eth0 interface. This configures eth0 for communication on the 10.1.1.0/24 network

# ip link add name vxlan10 type vxlan id 10 dev eth0 remote 10.1.1.2 local 10.1.1.1 dstport 4789
# Creates a VXLAN interface named vxlan10 with:
# VXLAN Network Identifier (VNI) 10
# Bound to the eth0 interface
# Local IP address 10.1.1.1 (the endpoint on this machine)
# Remote IP address 10.1.1.2 (the other VXLAN endpoint)
# Destination UDP port 4789 (standard VXLAN port)

# ip link set dev vxlan10 up
# Activates the vxlan10 interface, bringing it online

# brctl addif br0 eth1
# Adds the eth1 interface to the br0 bridge. Traffic from eth1 will now be bridged through br0

# brctl addif br0 vxlan10
# Adds the vxlan10 interface to the br0 bridge, allowing VXLAN traffic to be bridged alongside eth1

init_routeur1() {
	docker exec $1 bash -c "
		ip link add br0 type bridge ;
		ip link set dev br0 up ;
		ip addr add 10.1.1.1/24 dev eth0 ;
		ip link add name vxlan10 type vxlan id 10 dev eth0 remote 10.1.1.2 local 10.1.1.1 dstport 4789 ;
		ip link set dev vxlan10 up ;
		brctl addif br0 eth1 ;
		brctl addif br0 vxlan10
	"
}


# ip link add br0 type bridge
# Creates a network bridge device named br0. A bridge connects multiple network interfaces at the data link layer (Layer 2)

# ip link set dev br0 up
# Activates the bridge device br0, bringing it online

# ip addr add 10.1.1.2/24 dev eth0
# Assigns the IP address 10.1.1.2 with a subnet mask of /24 (255.255.255.0) to the eth0 interface. This configures eth0 for communication on the 10.1.1.0/24 network

# ip link add name vxlan10 type vxlan id 10 dev eth0 remote 10.1.1.1 local 10.1.1.2 dstport 4789
# Creates a VXLAN interface named vxlan10 with:
# VXLAN Network Identifier (VNI) 10
# Bound to the eth0 interface
# Local IP address 10.1.1.2 (the endpoint on this machine)
# Remote IP address 10.1.1.1 (the other VXLAN endpoint)
# Destination UDP port 4789 (standard VXLAN port)

# ip link set dev vxlan10 up
# Activates the vxlan10 interface, bringing it online

# brctl addif br0 eth1
# Adds the eth1 interface to the br0 bridge. Traffic from eth1 will now be bridged through br0

# brctl addif br0 vxlan10
# Adds the vxlan10 interface to the br0 bridge, allowing VXLAN traffic to be bridged alongside eth1

init_routeur2() {
	docker exec $1 bash -c "
		ip link add br0 type bridge ;
		ip link set dev br0 up ;
		ip addr add 10.1.1.2/24 dev eth0 ;
		ip link add name vxlan10 type vxlan id 10 dev eth0 remote 10.1.1.1 local 10.1.1.2 dstport 4789 ;
		ip addr add 20.1.1.2/24 dev vxlan10 ;
		ip link set dev vxlan10 up ;
		brctl addif br0 eth1 ;
		brctl addif br0 vxlan10
	"
}

for docker_item in $DOCKER; do
	if [[ $(docker exec $docker_item hostname) =~ ^host.*-1$ ]]; then
		init_host1 $docker_item
	elif [[ $(docker exec $docker_item hostname) =~ ^host.*-2$ ]]; then
		init_host2 $docker_item
	elif [[ $(docker exec $docker_item hostname) =~ ^routeur.*-1$ ]]; then
		init_routeur1 $docker_item
	elif [[ $(docker exec $docker_item hostname) =~ ^routeur.*-2$ ]]; then
		init_routeur2 $docker_item
	fi
done
