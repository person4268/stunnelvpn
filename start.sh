#!/usr/bin/zsh
TARGET= #who you're connecting to with stunnel
OVPN= #openvpn .ovpn file
cd #directory you're putting this in

GREEN='\033[0;32m'
ORANGE='\033[0;33m'
NC='\033[0m' # No Color

if [ $EUID -ne 0 ]
then
	echo "you forgot sudo so i fixed it for you"
	sudo $0
	exit
fi

echo "${GREEN}Starting stunnel${NC}"
echo -n "${ORANGE}"
(journalctl -f | grep stunnel) &
stunnel /etc/stunnel/stunnel.conf
echo -n ${NC}


#Only works when NOT connected to openvpn
#But doesn't matter since setting before connecting
GATEWAY=$(route -n | awk '$4 == "UG" {print $2}')


#Make sure openvpn doesn't route the VPN connection through itself
echo "${GREEN}Adding ip route${NC}"
ip route add $TARGET via $GATEWAY

echo "${GREEN}Starting OpenVPN${NC}"
openvpn --config "${OVPN}"


echo "${GREEN}Removing ip route${NC}"
ip route del $TARGET
echo "${GREEN}Killing stunnel${NC}"
pkill stunnel
