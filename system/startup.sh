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
ifconfig eth0 down
ifconfig eth0:10 down

# connect eth0 (dynamic ip)
ifconfig eth0 up
dhclient eth0

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
sudo /sbin/iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
sudo /sbin/iptables -A FORWARD -i eth0 -o wlan0 -m state --state RELATED,ESTABLISHED -j ACCEPT
sudo /sbin/iptables -A FORWARD -i wlan0 -o eth0 -j ACCEPT

#start haveged
sudo /etc/init.d/haveged start
 
# start chilli
service chilli start
 
#Start up management interface
ifconfig eth0:9 up
ip addr add 192.168.254.254/24 dev eth0:9


ln  -sf  /usr/local/lib/libpcap.so.1.0.0  /usr/lib/i386-linux-gnu/libpcap.so.0.8
# set wlan sniffer interface
iw dev mon.ihost del
iw dev wlan0 interface add mon.ihost type monitor
ip link set mon.ihost promisc on
ifconfig mon.ihost up
