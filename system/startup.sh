#!/bin/sh

#Stop named, if already running. dnsmasq cannot run because it take up port 53 
sudo killall named                                                              
#Stop dnsmasq, if already running 
sudo /usr/sbin/service dnsmasq stop 
#Stop hostapd, if already running                                               
sudo /usr/bin/pkill hostapd
#stop haveged                                                                   
sudo /etc/init.d/haveged stop

ifconfig wlan0 down
ifconfig p1p1 down
ifconfig p4p1 down

# connect p1p1 (dynamic ip)
ifconfig p1p1 up
dhclient p1p1

#Set ip on wlan0
ifconfig wlan0 up
/sbin/ip addr add 172.16.0.1/16 dev wlan0
#start hostapd
service hostapd start

#Start dnsmasq 
sudo /usr/sbin/service dnsmasq start

#Start ip_forward 
sudo echo 1 > /proc/sys/net/ipv4/ip_forward
#add iptables rule for NAT 
sudo /sbin/iptables -F
sudo /sbin/iptables -X
sudo /sbin/iptables -t nat -F
sudo /sbin/iptables -t nat -X
sudo /sbin/iptables -t mangle -F
sudo /sbin/iptables -t mangle -X
sudo /sbin/iptables -t nat -A POSTROUTING -o p1p1 -j MASQUERADE
sudo /sbin/iptables -A FORWARD -i p1p1 -o wlan0 -m state --state RELATED,ESTABLISHED -j ACCEPT
sudo /sbin/iptables -A FORWARD -i wlan0 -o p1p1 -j ACCEPT

#start haveged
sudo /etc/init.d/haveged start
 
# start chilli
service chilli start
 
#Start up management interface
ifconfig p1p1:9 up
ip addr add 192.168.254.254/24 dev p1p1:9


# set wlan sniffer interface
iw dev mon.ihost del
iw dev wlan0 interface add mon.ihost type monitor
ip link set mon.ihost promisc on
ifconfig mon.ihost up
