#bash switch ihost mode : create a startup.sh in the same directory. 
#it should be excuted in /root, and create "/root/startup.sh" 
#/root/startup.sh will be called from /etc/init.d/rc.local at system boot
#
#usage : bash ihostmod.sh  LANIF WANIF WLAN_SNIFFER_IF LAN_SNIFFER
#example:
#bash ihostmod.sh wlan1 wlan0 : smartphone connect to wlan1(hostapd), ihost uplink through wlan0 (dhcp required), no wlan sniffer,no lan sniffer
#bash ihostmod.sh wlan1 eth0 : smartphone connect to wlan1(hostapd), ihost uplink through eth0 (dhcp required), no wlan sniffer,no lan sniffer
#bash ihostmod.sh eth0 eth0 : smartphone connect to outside router, and then to ihost through eth0(static ip), no wlan sniffer,no lan sniffer
#bash ihostmod.sh eth0 eth0dhcp : smartphone connect to outside router, and then to ihost through eth0(one ip dhcp required), no wlan sniffer,no lan sniffer
#bash ihostmod.sh x x wlan1 eth0 : wlan sniffer on wlan1, lan sniffer on eth0 (ihost with a wireless router)
#bash ihostmod.sh x x rpcap://192.168.100.10/wlan100  eth0 : wlan sniffer on rpcap://192.168.100.10/wlan100, lan sniffer on eth0(ihost with a ruckus ap)
#bash ihostmod.sh x x wlan1 wlan1 : wlan sniffer on wlan1, lan sniffer on wlan1(ihost without a wireless router or ruckus ap)

# should be excute in 
#!/bin/sh
#echo arguments to the shell
echo 'Using LAN IF : '$1  ' / WAN IF : ' $2 '...'
echo 'Using WLAN SNIF IF : '$3  ' / LAN SNIF IF : ' $4 '...'

put_head_to_startup(){
rm ./startup.sh

cat >> ./startup.sh << EOF
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
cat >> ./startup.sh << EOF
# connect wlan0 to wifi
ifconfig wlan0 up
wpa_supplicant -B -iwlan0 -c /etc/wpa_supplicant.conf -Dwext
dhclient wlan0

EOF
}

put_eth0_connect_to_startup(){
cat >> ./startup.sh << EOF
# connect eth0 (dynamic ip)
ifconfig eth0 up
dhclient eth0

EOF
}

put_eth0_0_connect_to_startup(){
cat >> ./startup.sh << EOF
# connect eth0 (static ip)
ifconfig eth0 up
ip addr add 192.168.100.200/24 dev eth0
route add -net 0.0.0.0/0 gw 192.168.100.100
EOF
}

put_eth0_1_connect_to_startup(){
cat >> ./startup.sh << EOF
# connect eth0:10
ifconfig eth0:10 up
ip addr add 172.16.0.1/16 dev eth0

EOF
}

put_wlan1_hostapd_to_startup(){
cat >> ./startup.sh << EOF                                         
#Set ip on wlan1
ifconfig wlan1 up
/sbin/ip addr add 172.16.0.1/16 dev wlan1
#start hostapd
service hostapd start

EOF
}

put_dnsmasq_to_startup(){
cat >> ./startup.sh << EOF
#Start dnsmasq 
sudo /usr/sbin/service dnsmasq start

EOF
}

put_iptables_to_startup(){
cat >> ./startup.sh << EOF
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
cat >> ./startup.sh << EOF
#start haveged
sudo /etc/init.d/haveged start
 
EOF
}

put_chilli_to_startup(){
cat >> ./startup.sh << EOF
# start chilli
service chilli start
 
EOF
}

put_manage_if_to_startup(){
cat >> ./startup.sh << EOF
#Start up management interface
ifconfig $MAN_IF up
ip addr add 192.168.254.254/24 dev $MAN_IF


EOF
}

put_eth0_ip_rm_to_startup(){
cat >> ./startup.sh << EOF
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
#bash ./startup.sh

# restart chilli
#service chilli restart

# clear ruckus's config file
rm ./ruckus

# put scripts into starup.sh : to  set wlan sniffer interface
# create wlan sniffer shell script (or not create)
if [ "-$3" = '-' ]
then
    echo "NO WLAN SNIFFER INTERFACE GIVEN, wlcap.wlan.sh WILL NOT BE CREATED..."
    exit 0 
else
    if [ "$3" = 'wlan1' ]
    then
        echo "# set wlan sniffer interface" >> ./startup.sh
        echo "iw dev mon.ihost del" >> ./startup.sh
        echo "iw dev wlan1 interface add mon.ihost type monitor" >> ./startup.sh
        echo "ip link set mon.ihost promisc on" >> ./startup.sh
        echo "ifconfig mon.ihost up" >> ./startup.sh
        WLAN_SNIF_IF=mon.wlan1
    else
        arr=($(echo $3 | tr '/' ' ' | tr -s ' '))
        REOMTE_IP=${arr[1]}
        echo 'Ruckus AP address: '$REOMTE_IP
        REOMTE_PASSWD='sp-admin'
        echo 'Default admin password: sp-admin'
        read -p "Input admin passrod (Press Enter key to accept default value): " INPUT
        if [ x$INPUT != x ]; then
            REOMTE_PASSWD=$INPUT
        fi
        echo 'Ruckus AP admin password : '$REOMTE_PASSWD

        # write to ruckus' config file
        echo $REOMTE_IP > ruckus
        echo $REOMTE_PASSWD >> ruckus
        WLAN_SNIF_IF=$3
    fi
    echo '#!/bin/sh' > ./wlcap.wlan.sh
    WLCMD="wlcap -i $WLAN_SNIF_IF -T fields -E separator=, -E quote=d -e frame.time -e frame.protocols -e radiotap.dbm_antsignal -e ppi.80211-common.dbm.antsignal -e wlan.sa -e wlan.bssid -e wlan_mgt.ssid -f \"subtype probe-req\""
    echo $WLCMD >> ./wlcap.wlan.sh
fi


# create lan sniffer shell script (or not create)
if [ "-$4" = '-' ]
then
    echo "NO LAN SNIFFER INTERFACE GIVEN, wlcap.lan.sh WILL NOT BE CREATED..."
    exit 0 
else
    LAN_SNIF_IF_MAC=`ifconfig $4 | grep $4|cut -d':' -f2-7|cut -d '' -f4 | awk '{print $3}'` 
    echo '#!/bin/sh' >  ./wlcap.lan.sh
    WLCMD="wlcap -i $4 -T fields -E separator=, -E quote=d -e frame.time -e eth.src -e ip.src -e ip.dst -e http.request.full_uri -f \"(src net 172.16.0.0/16) and (not (dst net 172.16.0.0/16)) and (dst port http or 8080 or https) and ((tcp-syn)!=0) and (not ether src $LAN_SNIF_IF_MAC)\""
    echo $WLCMD >> ./wlcap.lan.sh
fi
