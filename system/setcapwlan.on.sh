#script to bring up wlcap.wlan.sh

#!/bin/sh
mkdir -p /wms/pkt/wlan
NOW=$(date +"%F")
NOWT=$(date +"%T")
FILE="/wms/pkt/wlan/$NOW-$NOWT.txt"
echo '\n' |  /root/wlcap.wlan.sh &> $FILE
