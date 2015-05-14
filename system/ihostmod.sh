#switch ihost mode 
#ihostmod wlan1 wlan0 : smartphone connect to wlan1(hostapd), ihost uplink through wlan0 (dhcp required)
#ihostmod wlan1 eth0 : smartphone connect to wlan1(hostapd), ihost uplink through eth0 (dhcp required)
#ihostmod eth0 eth0 : smartphone connect to outside router through eth0

#!/bin/sh
#echo arguments to the shell
echo 'Using LAN IF : '$1  ' / WAN IF : ' $2 '...'

put_head_to_startup(){
rm /root/startup.sh

cat >> /root/startup.sh << EOF
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
ifconfig wlan1 down
ifconfig eth0 down
ifconfig eth0:10 down

EOF
}

put_wlan0_connect_to_startup(){
cat >> /root/startup.sh << EOF
# connect wlan0 to wifi
ifconfig wlan0 up
wpa_supplicant -B -iwlan0 -c /etc/wpa_supplicant.conf -Dwext
dhclient wlan0

EOF
}

put_eth0_connect_to_startup(){
cat >> /root/startup.sh << EOF
# connect eth0 (dynamic ip)
ifconfig eth0 up
dhclient eth0

EOF
}

put_eth0_0_connect_to_startup(){
cat >> /root/startup.sh << EOF
# connect eth0 (static ip)
ifconfig eth0 up
ip addr add 192.168.100.200/24 dev eth0
route add -net 0.0.0.0/0 gw 192.168.100.100
EOF
}

put_eth0_1_connect_to_startup(){
cat >> /root/startup.sh << EOF
# connect eth0:10
ifconfig eth0:10 up
ip addr add 172.16.0.1/16 dev eth0

EOF
}

put_wlan1_hostapd_to_startup(){
cat >> /root/startup.sh << EOF                                         
#Set ip on wlan1
ifconfig wlan1 up
/sbin/ip addr add 172.16.0.1/16 dev wlan1
#start hostapd
service hostapd start

EOF
}

put_dnsmasq_to_startup(){
cat >> /root/startup.sh << EOF
#Start dnsmasq 
sudo /usr/sbin/service dnsmasq start

EOF
}

put_iptables_to_startup(){
cat >> /root/startup.sh << EOF
#Start ip_forward 
sudo echo 1 > /proc/sys/net/ipv4/ip_forward
#add iptables rule for NAT 
sudo /sbin/iptables -F
sudo /sbin/iptables -X
sudo /sbin/iptables -t nat -F
sudo /sbin/iptables -t nat -X
sudo /sbin/iptables -t mangle -F
sudo /sbin/iptables -t mangle -X
sudo /sbin/iptables -t nat -A POSTROUTING -o $WAN_IF -j MASQUERADE
sudo /sbin/iptables -A FORWARD -i $WAN_IF -o $LAN_IF -m state --state RELATED,ESTABLISHED -j ACCEPT
sudo /sbin/iptables -A FORWARD -i $LAN_IF -o $WAN_IF -j ACCEPT

EOF
}

put_haveged_to_startup(){
cat >> /root/startup.sh << EOF
#start haveged
sudo /etc/init.d/haveged start
 
EOF
}

put_chilli_to_startup(){
cat >> /root/startup.sh << EOF
# start chilli
service chilli start
 
EOF
}

put_manage_if_to_startup(){
cat >> /root/startup.sh << EOF
#Start up management interface
ifconfig $MAN_IF up
ip addr add 192.168.254.254/24 dev $MAN_IF


EOF
}

put_eth0_ip_rm_to_startup(){
cat >> /root/startup.sh << EOF
# remove 172.16.0.1 from eth0
ip addr del 172.16.0.1/16 dev eth0

EOF
}

#HS_WANIF=wlan0 # WAN Interface toward the Internet
CHILLI_WAN_IF_OLD=`cat /etc/chilli/defaults | grep HS_WANIF=`
HS_LANIF=wlan1 # Subscriber Interface for client devices
CHILLI_LAN_IF_OLD=`cat /etc/chilli/defaults | grep HS_LANIF=`

#IGNORE_RESOLVCONF=yes
DNSMASQ_RESOLVCONF=`cat /etc/default/dnsmasq | grep IGNORE_RESOLVCONF=`
#resolv-file=/etc/resolv.dnsmasq.conf
DNSMASQ_RESOLVFILE=`cat /etc/dnsmasq.conf | grep resolv-file=`

if [ "$1" = 'wlan1' -a  "$2" = 'wlan0' ]
then
    WAN_IF='wlan0'
    LAN_IF='wlan1'
    MAN_IF='eth0'

    put_head_to_startup
    put_wlan0_connect_to_startup
    put_wlan1_hostapd_to_startup
    put_dnsmasq_to_startup
    put_iptables_to_startup
    put_haveged_to_startup
    put_chilli_to_startup
    put_manage_if_to_startup
    sed  -i  "s|$DNSMASQ_RESOLVCONF|#IGNORE_RESOLVCONF=yes|g"  /etc/default/dnsmasq
    sed  -i  "s|$DNSMASQ_RESOLVFILE|#resolv-file=/etc/resolv.dnsmasq.conf|g"  /etc/dnsmasq.conf

elif [ "$1" = 'wlan1' -a  "$2" = 'eth0' ]
then
    WAN_IF='eth0'
    LAN_IF='wlan1'
    MAN_IF='eth0:9'

    put_head_to_startup
    put_eth0_connect_to_startup
    put_wlan1_hostapd_to_startup
    put_dnsmasq_to_startup
    put_iptables_to_startup
    put_haveged_to_startup
    put_chilli_to_startup
    put_manage_if_to_startup
    sed  -i  "s|$DNSMASQ_RESOLVCONF|#IGNORE_RESOLVCONF=yes|g"  /etc/default/dnsmasq
    sed  -i  "s|$DNSMASQ_RESOLVFILE|#resolv-file=/etc/resolv.dnsmasq.conf|g"  /etc/dnsmasq.conf

elif [ "$1" = 'eth0' -a  "$2" = 'eth0' ]
then
    WAN_IF='eth0'
    LAN_IF='eth0:10'
    MAN_IF='eth0:9'

    put_head_to_startup
    put_eth0_0_connect_to_startup
    put_eth0_1_connect_to_startup
    put_dnsmasq_to_startup
    put_iptables_to_startup
    put_chilli_to_startup
    put_manage_if_to_startup
    put_eth0_ip_rm_to_startup

    sed  -i  "s|$DNSMASQ_RESOLVCONF|IGNORE_RESOLVCONF=yes|g"  /etc/default/dnsmasq
    sed  -i  "s|$DNSMASQ_RESOLVFILE|resolv-file=/etc/resolv.dnsmasq.conf|g"  /etc/dnsmasq.conf

elif [ "$1" = 'eth0' -a  "$2" = 'eth0dhcp' ]
then
    WAN_IF='eth0'
    LAN_IF='eth0:10'
    MAN_IF='eth0:9'

    put_head_to_startup
    put_eth0_connect_to_startup
    put_eth0_1_connect_to_startup
    put_dnsmasq_to_startup
    put_iptables_to_startup
    put_chilli_to_startup
    put_manage_if_to_startup
    put_eth0_ip_rm_to_startup

    sed  -i  "s|$DNSMASQ_RESOLVCONF|#IGNORE_RESOLVCONF=yes|g"  /etc/default/dnsmasq
    sed  -i  "s|$DNSMASQ_RESOLVFILE|#resolv-file=/etc/resolv.dnsmasq.conf|g"  /etc/dnsmasq.conf

else
    echo "Error!!! check your input!!!"
    exit 0
fi

# update chilli config
CHILLI_WAN_IF='HS_WANIF='$WAN_IF
CHILLI_LAN_IF='HS_LANIF='$LAN_IF
sed  -i  "s|$CHILLI_WAN_IF_OLD|$CHILLI_WAN_IF|g"  /etc/chilli/defaults
sed  -i  "s|$CHILLI_LAN_IF_OLD|$CHILLI_LAN_IF|g"  /etc/chilli/defaults

# excute startup.sh
#bash /root/startup.sh

# restart chilli
#service chilli restart
