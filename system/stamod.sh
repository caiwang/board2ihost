#switch station mode : modify startup.sh (and /etc/wpa_supplicant.conf)
#usage : bash stamod.sh  ssid open/secu password
#example:
#bash stamod.sh ssid-a open : connect to ssid-a, open without password
#bash apmod.sh ssid-b  secu 123456 : connect to ssid-b, secured without password 123456(wpa2)

#!/bin/sh
#echo arguments to the shell
echo 'SSID : '$1  ' / Security : ' $2 
echo 'Password : '$3

# current settings in startup.sh
#wpa_supplicant -B -iwlan0 -c /etc/wpa_supplicant.conf -Dwext
LINE_WPA=`cat /root/startup.sh | grep wpa_supplicant`
#iwconfig wlan0 mode Managed
LINE_MODE=`cat /root/startup.sh | grep 'iwconfig wlan0 mode Managed'`
#iwconfig wlan0 essid "mtxwifi"
LINE_SSID=`cat /root/startup.sh | grep 'iwconfig wlan0 essid'`

if [ "$2" = 'secu' ]
then
    if [ "-$LINE_WPA" != '-' ]; then
        sed  -i  "s|$LINE_WPA|wpa_supplicant -B -iwlan0 -c /etc/wpa_supplicant.conf -Dwext|g"  /root/startup.sh
        rm  /etc/wpa_supplicant.conf
        echo "ctrl_interface=/var/run/wpa_supplicant" > /etc/wpa_supplicant.conf
        echo "network={" >> /etc/wpa_supplicant.conf
        echo "   ssid=\"$1\"" >> /etc/wpa_supplicant.conf
        echo "   psk=\"$3\"" >> /etc/wpa_supplicant.conf
        echo "}" >> /etc/wpa_supplicant.conf
    fi
    if [ "-$LINE_MODE" != '-' ]; then
        sed  -i  "s|$LINE_MODE|#iwconfig wlan0 mode Managed|g"  /root/startup.sh
    fi
    if [ "-$LINE_SSID" != '-' ]; then
        sed  -i  "s|$LINE_SSID|#iwconfig wlan0 essid \"mtxwifi\"|g"  /root/startup.sh
    fi

elif [ "$2" = 'open' ]
then
    if [ "-$LINE_WPA" != '-' ]; then
        sed  -i  "s|$LINE_WPA|#wpa_supplicant -B -iwlan0 -c /etc/wpa_supplicant.conf -Dwext|g"  /root/startup.sh
    fi
    if [ "-$LINE_MODE" != '-' ]; then
        sed  -i  "s|$LINE_MODE|iwconfig wlan0 mode Managed|g"  /root/startup.sh
    fi
    if [ "-$LINE_SSID" != '-' ]; then
        sed  -i  "s|$LINE_SSID|iwconfig wlan0 essid \"$1\"|g"  /root/startup.sh
    fi
else
    echo "Error! CHECK YOUR INPUT!"
fi

