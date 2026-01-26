#!/bin/bash

DOCKER=$(docker ps -q)


##############
# INIT HOST1 #
##############

# ip addr add 30.1.1.1/24 dev eth1
# Assigns the IP address 30.1.1.1 with a subnet mask of /24 (255.255.255.0) to the eth1 interface. This configures eth1 for communication on the 10.1.1.0/24 network

init_host1() {
	docker exec $1 ip addr add 30.1.1.1/24 dev eth1
}


##############
# INIT HOST2 #
##############

# ip addr add 30.1.1.2/24 dev eth0
# Assigns the IP address 30.1.1.2 with a subnet mask of /24 (255.255.255.0) to the eth0 interface. This configures eth0 for communication on the 10.1.1.0/24 network

init_host2() {
	docker exec $1 ip addr add 30.1.1.2/24 dev eth0
}


##############
# INIT HOST3 #
##############

# ip addr add 30.1.1.3/24 dev eth0
# Assigns the IP address 30.1.1.3 with a subnet mask of /24 (255.255.255.0) to the eth0 interface. This configures eth0 for communication on the 10.1.1.0/24 network

init_host3() {
	docker exec $1 ip addr add 30.1.1.3/24 dev eth0
}


##############
# INIT LEAF1 #
##############

# ip link add br0 type bridge
# Creates a network bridge device named br0. A bridge connects multiple network interfaces at the data link layer (Layer 2)

# ip link set dev br0 up
# Activates the bridge device br0, bringing it online

# ip link add name vxlan10 type vxlan id 10 dstport 4789 ;
# Creates a VXLAN interface named vxlan10 with:
# VXLAN Network Identifier (VNI) 10.
# Destination UDP port 4789 (standard VXLAN port)

# ip link set dev vxlan10 up
# Activates the vxlan10 interface, bringing it online

# brctl addif br0 eth1
# Adds the eth1 interface to the br0 bridge. Traffic from eth1 will now be bridged through br0

# brctl addif br0 vxlan10
# Adds the vxlan10 interface to the br0 bridge, allowing VXLAN traffic to be bridged alongside eth1

init_leaf1() {
	docker exec $1 bash -c "
		ip link add br0 type bridge ;
		ip link set dev br0 up ;
		ip link add name vxlan10 type vxlan id 10 dstport 4789 ;
		ip link set dev vxlan10 up ;
		brctl addif br0 eth1 ;
		brctl addif br0 vxlan10
	"

	docker exec $1 vtysh -c "
		configure terminal

		# Set the router hostname for identification and troubleshooting
		hostname leaf_alpine_frrouting_mcordes-1

		# Disable IPv6 forwarding (IPv6 not used in this lab)
		no ipv6 forwarding



		# Configure the underlay interface towards the Route Reflector
		interface eth0

		 # Assign a point-to-point underlay IP address
		 ip address 10.1.1.2/30

		 # Enable OSPF on this interface (backbone area)
		 ip ospf area 0



		# Configure a loopback interface for stable router identification
		interface lo

		 # Assign a /32 loopback IP address
		 ip address 1.1.1.2/32

	 	 # Advertise the loopback into OSPF
		 ip ospf area 0



		# Start BGP in AS 1 (iBGP)
		router bgp 1

		 # Define the Route Reflector as an iBGP neighbor
		 neighbor 1.1.1.1 remote-as 1

		 # Use the loopback interface as the BGP source address
		 neighbor 1.1.1.1 update-source lo

		 # Enter the EVPN address family
		 address-family l2vpn evpn

		  # Activate the EVPN session with the Route Reflector
		  neighbor 1.1.1.1 activate

		  # Automatically advertise all configured VXLAN VNIs
		  advertise-all-vni

		 exit-address-family



		# Enable the OSPF routing process
		router ospf
	"
}


##############
# INIT LEAF2 #
##############

# ip link add br0 type bridge
# Creates a network bridge device named br0. A bridge connects multiple network interfaces at the data link layer (Layer 2)

# ip link set dev br0 up
# Activates the bridge device br0, bringing it online

# ip link add name vxlan10 type vxlan id 10 dstport 4789 ;
# Creates a VXLAN interface named vxlan10 with:
# VXLAN Network Identifier (VNI) 10.
# Destination UDP port 4789 (standard VXLAN port)

# ip link set dev vxlan10 up
# Activates the vxlan10 interface, bringing it online

# brctl addif br0 eth0
# Adds the eth1 interface to the br0 bridge. Traffic from eth1 will now be bridged through br0

# brctl addif br0 vxlan10
# Adds the vxlan10 interface to the br0 bridge, allowing VXLAN traffic to be bridged alongside eth0

init_leaf2() {
	docker exec $1 bash -c "
		ip link add br0 type bridge ;
		ip link set dev br0 up ;
		ip link add name vxlan10 type vxlan id 10 dstport 4789 ;
		ip link set dev vxlan10 up ;
		brctl addif br0 eth0 ;
		brctl addif br0 vxlan10
	"

	docker exec $1 vtysh -c "
		configure terminal

		# Set the router hostname for identification and troubleshooting
		hostname leaf_alpine_frrouting_mcordes-2

		# Disable IPv6 forwarding (IPv6 not used in this lab)
		no ipv6 forwarding



		# Configure the underlay interface towards the Route Reflector
		interface eth1

		 # Assign a point-to-point underlay IP address
		 ip address 10.1.1.6/30

		 # Enable OSPF on this interface (backbone area)
		 ip ospf area 0



		# Configure a loopback interface for stable router identification
		interface lo

		 # Assign a /32 loopback IP address
		 ip address 1.1.1.3/32

	 	 # Advertise the loopback into OSPF
		 ip ospf area 0



		# Start BGP in AS 1 (iBGP)
		router bgp 1

		 # Define the Route Reflector as an iBGP neighbor
		 neighbor 1.1.1.1 remote-as 1

		 # Use the loopback interface as the BGP source address
		 neighbor 1.1.1.1 update-source lo

		 # Enter the EVPN address family
		 address-family l2vpn evpn

		  # Activate the EVPN session with the Route Reflector
		  neighbor 1.1.1.1 activate

		  # Automatically advertise all configured VXLAN VNIs
		  advertise-all-vni

		 exit-address-family



		# Enable the OSPF routing process
		router ospf
	"
}


##############
# INIT LEAF3 #
##############

# ip link add br0 type bridge
# Creates a network bridge device named br0. A bridge connects multiple network interfaces at the data link layer (Layer 2)

# ip link set dev br0 up
# Activates the bridge device br0, bringing it online

# ip link add name vxlan10 type vxlan id 10 dstport 4789 ;
# Creates a VXLAN interface named vxlan10 with:
# VXLAN Network Identifier (VNI) 10.
# Destination UDP port 4789 (standard VXLAN port)

# ip link set dev vxlan10 up
# Activates the vxlan10 interface, bringing it online

# brctl addif br0 eth0
# Adds the eth1 interface to the br0 bridge. Traffic from eth1 will now be bridged through br0

# brctl addif br0 vxlan10
# Adds the vxlan10 interface to the br0 bridge, allowing VXLAN traffic to be bridged alongside eth0

init_leaf3() {
	docker exec $1 bash -c "
		ip link add br0 type bridge ;
		ip link set dev br0 up ;
		ip link add name vxlan10 type vxlan id 10 dstport 4789 ;
		ip link set dev vxlan10 up ;
		brctl addif br0 eth0 ;
		brctl addif br0 vxlan10
	"

	docker exec $1 vtysh -c "
		configure terminal

		# Set the router hostname for identification and troubleshooting
		hostname leaf_alpine_frrouting_mcordes-3

		# Disable IPv6 forwarding (IPv6 not used in this lab)
		no ipv6 forwarding



		# Configure the underlay interface towards the Route Reflector
		interface eth2

		 # Assign a point-to-point underlay IP address
		 ip address 10.1.1.10/30

		 # Enable OSPF on this interface (backbone area)
		 ip ospf area 0



		# Configure a loopback interface for stable router identification
		interface lo

		 # Assign a /32 loopback IP address
		 ip address 1.1.1.4/32

	 	 # Advertise the loopback into OSPF
		 ip ospf area 0



		# Start BGP in AS 1 (iBGP)
		router bgp 1

		 # Define the Route Reflector as an iBGP neighbor
		 neighbor 1.1.1.1 remote-as 1

		 # Use the loopback interface as the BGP source address
		 neighbor 1.1.1.1 update-source lo

		 # Enter the EVPN address family
		 address-family l2vpn evpn

		  # Activate the EVPN session with the Route Reflector
		  neighbor 1.1.1.1 activate

		  # Automatically advertise all configured VXLAN VNIs
		  advertise-all-vni

		 exit-address-family



		# Enable the OSPF routing process
		router ospf
	"
}


###########
# INIT RR #
###########

init_rr() {
	docker exec $1 vtysh -c "
		configure terminal
	
		# Set the Route Reflector hostname
		hostname rr_mcordes
	
		# Disable IPv6 forwarding
		no ipv6 forwarding
	
		# Underlay link towards LEAF1
		interface eth0
			# Assign point-to-point IP address
			ip address 10.1.1.1/30

	
		# Underlay link towards LEAF2
		interface eth1
			# Assign point-to-point IP address
			ip address 10.1.1.5/30

	
		# Underlay link towards LEAF3
		interface eth2
			# Assign point-to-point IP address
			ip address 10.1.1.9/30

	
		# Loopback interface used as BGP router-id and session endpoint
		interface lo
			# Assign a /32 loopback address
			ip address 1.1.1.1/32

	
		# Start BGP in AS 1 (iBGP)
		router bgp 1
	
			# Create an iBGP peer-group for all leaf switches
			neighbor ibgp peer-group
	
			# Define common iBGP parameters
			neighbor ibgp remote-as 1
			neighbor ibgp update-source lo
	
			# Dynamically accept iBGP neighbors in this IP range
			bgp listen range 1.1.1.0/29 peer-group ibgp

	
			# Enter the EVPN address family
			address-family l2vpn evpn
	
				# Activate EVPN for all iBGP peers
				neighbor ibgp activate
	
				# Configure peers as Route Reflector clients
				neighbor ibgp route-reflector-client
	
			exit-address-family

	

		# Enable OSPF and advertise all interfaces
		router ospf
			# Enable OSPF on all interfaces in area 0
			network 0.0.0.0/0 area 0
	"
}


for docker_item in $DOCKER; do
	if [[ $(docker exec $docker_item hostname) =~ ^host.*-1$ ]]; then
		init_host1 $docker_item
	elif [[ $(docker exec $docker_item hostname) =~ ^host.*-2$ ]]; then
		init_host2 $docker_item
	elif [[ $(docker exec $docker_item hostname) =~ ^host.*-3$ ]]; then
		init_host3 $docker_item
	elif [[ $(docker exec $docker_item hostname) =~ ^leaf.*-1$ ]]; then
		init_leaf1 $docker_item
	elif [[ $(docker exec $docker_item hostname) =~ ^leaf.*-2$ ]]; then
		init_leaf2 $docker_item
	elif [[ $(docker exec $docker_item hostname) =~ ^leaf.*-3$ ]]; then
		init_leaf3 $docker_item
	elif [[ $(docker exec $docker_item hostname) =~ ^rr.*$ ]]; then
		init_rr $docker_item
	fi
done
