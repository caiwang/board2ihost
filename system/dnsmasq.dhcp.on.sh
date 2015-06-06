#!/bin/bash
sed  -i  's|#interface=wlan0|interface=wlan0|g'  /etc/dnsmasq.conf
sed  -i  's|#bind-interfaces|bind-interfaces|g'  /etc/dnsmasq.conf
sed  -i  's|#except-interface=lo|except-interface=lo|g'  /etc/dnsmasq.conf
sed  -i  's|#dhcp-range=wlan1,172.16.0.100,172.16.0.200,2h|dhcp-range=wlan1,172.16.0.100,172.16.0.200,2h|g'  /etc/dnsmasq.conf
sed  -i  's|#dhcp-option=option:router,172.16.0.1|dhcp-option=option:router,172.16.0.1|g'  /etc/dnsmasq.conf
sed  -i  's|#dhcp-option=option:dns-server,0.0.0.0,172.16.0.1|dhcp-option=option:dns-server,0.0.0.0,172.16.0.1|g'  /etc/dnsmasq.conf
sed  -i  's|#dhcp-option=option:domain-name,mtxwifi.net|dhcp-option=option:domain-name,mtxwifi.net|g'  /etc/dnsmasq.conf
