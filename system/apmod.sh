#switch AP mode : create /etc/hostapd/hostapd.conf.std 
#usage : bash apmod.sh  ssid channel vis/hid open/secu password
#example:
#bash apmod.sh ssid-a 1 vis open : ssid-a,channel 1,visible, open without password
#bash apmod.sh ssid-b 6 hid secu 12345678 : ssid-b,channel 6,not visible, secured without password 12345678(8bits required)

#!/bin/sh
#echo arguments to the shell
echo 'SSID : '$1  ' / CHANNEL : ' $2 
echo 'Visibility : '$3  ' / Security : ' $4 
echo 'Password : '$5

rm  /etc/hostapd/hostapd.conf.std 
cat > /etc/hostapd/hostapd.conf.std << EOF
interface=wlan1
driver=nl80211
hw_mode=g
macaddr_acl=0
auth_algs=1
wmm_enabled=0
max_num_sta=15

EOF

echo "ssid=$1" >> /etc/hostapd/hostapd.conf.std 
echo "channel=$2" >> /etc/hostapd/hostapd.conf.std 

if [ "$3" = 'hid' ]
then
    echo "ignore_broadcast_ssid=1" >> /etc/hostapd/hostapd.conf.std 
else
    echo "ignore_broadcast_ssid=0" >> /etc/hostapd/hostapd.conf.std 
fi

if [ "$4" = 'secu' ]
then
    echo "wpa=2" >> /etc/hostapd/hostapd.conf.std 
    echo "wpa_passphrase=$5" >> /etc/hostapd/hostapd.conf.std 
    echo "wpa_key_mgmt=WPA-PSK" >> /etc/hostapd/hostapd.conf.std 
    echo "wpa_pairwise=TKIP CCMP" >> /etc/hostapd/hostapd.conf.std
    echo "rsn_pairwise=TKIP CCMP" >> /etc/hostapd/hostapd.conf.std 
fi
