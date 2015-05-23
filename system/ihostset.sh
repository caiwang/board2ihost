#setting up ihost
#ihostset.sh  [bandwidth session idle clientdns systime wlansniff lansniff dnsspoof upstreamdns reboot ]  
#
#  bandwidth [upload bps] [download bps]
#  session  [seconds]
#  idle [seconds]
#  clientdns [ipaddr]
#  systime  [ntp local] [3.cn.pool.ntp.org 2015-5-23 10:47:00]
#  wlansniff [on off]
#  lansniff [on off]
#  dnsspoof [on off] [ipaddr]
#  upstreamdns [ipaddr -]
#  reboot
#usage : bash ihostset.sh item parameters 
#example:
# bash /root/ihostset.sh bandwidth
# bash /root/ihostset.sh bandwidth 20480 40960
# bash /root/ihostset.sh session 
# bash /root/ihostset.sh session 1200
# bash /root/ihostset.sh idle 
# bash /root/ihostset.sh idle 600
# bash /root/ihostset.sh clientdns # to remove dns2
# bash /root/ihostset.sh clientdns 202.106.46.151 # to set dns2
# bash /root/ihostset.sh systime local 'May 23 12:46:49 CST 2015'
# bash /root/ihostset.sh systime ntp 
# bash /root/ihostset.sh systime ntp 2.cn.pool.ntp.org
# bash /root/ihostset.sh wlansniff on
# bash /root/ihostset.sh wlansniff off
# bash /root/ihostset.sh lansniff on
# bash /root/ihostset.sh lansniff off
# bash /root/ihostset.sh dnsspoof on 192.168.1.1 # dnsspoof in /etc/dnsmasq.conf
# bash /root/ihostset.sh dnsspoof on  # dnsspoof in /etc/dnsmasq.conf default 1.1.1.1
# bash /root/ihostset.sh dnsspoof off # remove dnsspoof in /etc/dnsmasq.conf
# bash /root/ihostset.sh upstreamdns 202.106.46.151 # to append a line in /etc/resolv.dnsmasq.conf
# bash /root/ihostset.sh upstreamdns -  # to delete the last line in /etc/resolv.dnsmasq.conf
# bash /root/ihostset.sh reboot

#!/bin/sh
#echo arguments to the shell
echo 'setting up '$1 
echo 'parameters : '$2' /  '$3' /  '$4' /  '$5

# current settings in startup.sh
#wpa_supplicant -B -iwlan0 -c /etc/wpa_supplicant.conf -Dwext
LINE_WPA=`cat /root/startup.sh | grep wpa_supplicant`
#iwconfig wlan0 mode Managed
LINE_MODE=`cat /root/startup.sh | grep 'iwconfig wlan0 mode Managed'`
#iwconfig wlan0 essid "mtxwifi"
LINE_SSID=`cat /root/startup.sh | grep 'iwconfig wlan0 essid'`

if [ "$1" = 'bandwidth' ]
then
    #Default bandwidth by bits per second
    maxUP=0
    maxDOWN=0
    LINE_MAXUP=`cat /etc/chilli/defaults | grep HS_DEFBANDWIDTHMAXUP`
    LINE_MAXDOWN=`cat /etc/chilli/defaults | grep HS_DEFBANDWIDTHMAXDOWN`
    if [ "-$2" != '-' ]; then
        maxUP="$2"
    fi
    if [ "-$3" != '-' ]; then
        maxDOWN="$3"
    fi
    sed  -i  "s|$LINE_MAXUP|HS_DEFBANDWIDTHMAXUP="$maxUP"|g"  /etc/chilli/defaults
    sed  -i  "s|$LINE_MAXDOWN|HS_DEFBANDWIDTHMAXDOWN="$maxDOWN"|g"  /etc/chilli/defaults    

elif [ "$1" = 'session' ]
then
    #Default session timeout by seconds
    maxSESSION=0
    LINE_SESSION=`cat /etc/chilli/defaults | grep HS_DEFSESSIONTIMEOUT`
    if [ "-$2" != '-' ]; then
        maxSESSION="$2"
    fi
    sed  -i  "s|$LINE_SESSION|HS_DEFSESSIONTIMEOUT="$maxSESSION"|g"  /etc/chilli/defaults

elif [ "$1" = 'idle' ]
then
    #Default idle timeout by seconds
    maxIDLE=0
    LINE_IDLE=`cat /etc/chilli/defaults | grep HS_DEFIDLETIMEOUT=`
    if [ "-$2" != '-' ]; then
        maxIDLE="$2"
    fi
    sed  -i  "s|$LINE_IDLE|HS_DEFIDLETIMEOUT="$maxIDLE"|g"  /etc/chilli/defaults

elif [ "$1" = 'clientdns' ]
then
    #DNS2 for chilli clients
    LINE_CLIENTDNS=`cat /etc/chilli/defaults | grep HS_DNS2=`
    if [ "-$2" != '-' ]; then
        DNS2='HS_DNS2='"$2"
    else
        DNS2='#HS_DNS2='
    fi
    sed  -i  "s|$LINE_CLIENTDNS|$DNS2|g"  /etc/chilli/defaults


elif [ "$1" = 'systime' ]
then
    if [ "$2" = 'local' -a "-$3" != '-' ]; then
        date -s "$3"
    else
        TIMESERVER='3.cn.pool.ntp.org'
        if [ "-$3" != '-' ]; then
            TIMESERVER="$3"
        fi
        ntpdate "$TIMESERVER"
    fi

elif [ "$1" = 'wlansniff' ]
then
    if [ "$2" = 'on' ]; then
        crontab -l | sed "/^#.*setcapwlan.off.*/s/^#//" | crontab -
        crontab -l | sed "/^#.*setcapwlan.on.*/s/^#//" | crontab -
    else
        crontab -l | sed "/^[^#].*setcapwlan.off.*/s/^/#/" | crontab -
        crontab -l | sed "/^[^#].*setcapwlan.on.*/s/^/#/" | crontab -
    fi
elif [ "$1" = 'lansniff' ]
then
    if [ "$2" = 'on' ]; then
        crontab -l | sed "/^#.*setcaplan.off.*/s/^#//" | crontab -
        crontab -l | sed "/^#.*setcaplan.on.*/s/^#//" | crontab -
    else
        crontab -l | sed "/^[^#].*setcaplan.off.*/s/^/#/" | crontab -
        crontab -l | sed "/^[^#].*setcaplan.on.*/s/^/#/" | crontab -
    fi
elif [ "$1" = 'dnsspoof' ]
then
    LINE_SPOOF=`cat /etc/dnsmasq.conf | grep address=/#/`
    IP_SPOOF='1.1.1.1'
    if [ "-$3" != '-' ]; then
        IP_SPOOF="$3"
    fi
    if [ "$2" = 'on' ]; then
        sed  -i  "s|$LINE_SPOOF|address=/#/$IP_SPOOF|g"  /etc/dnsmasq.conf
    else
        sed  -i  "s|$LINE_SPOOF|#address=/#/$IP_SPOOF|g"  /etc/dnsmasq.conf
    fi

elif [ "$1" = 'upstreamdns' ]
then
    if [ "-$2" != '-' ]; then
        if [ "$2" = '-' ]; then
            sed -i '$ d' /etc/resolv.dnsmasq.conf
        else
            echo 'nameserver '"$2" >> /etc/resolv.dnsmasq.conf
        fi
    fi


elif [ "$1" = 'reboot' ]
then
    reboot
    reboot

else
    echo "Error! CHECK YOUR INPUT!"
fi


