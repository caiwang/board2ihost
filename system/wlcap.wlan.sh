#!/bin/sh
wlcap -l -i mon.ihost -T fields -E separator=, -e wlan.fc.type_subtype -e wlan.sa -e frame.time_epoch -e frame.protocols -e radiotap.dbm_antsignal -e ppi.80211-common.dbm.antsignal -e wlan_mgt.ssid -Y "wlan.fc.type_subtype==0x04"
