#script to bring up wlcap.wlan.sh

#!/bin/sh
#use ramdisk
dirBASE='/run/shm'
#use sd card
#dirBASE='/wms'
mkdir -p $dirBASE/pkt/wlan
NOW=$(date +"%F")
NOWT=$(date +"%T")
minNOWT=$(echo $NOWT | sed 's/://g;s/..$//')
FILE="$dirBASE/pkt/wlan/$NOW-$minNOWT"
echo "wlFILE=$FILE" > $dirBASE/pkt/wlan/.workingfile
echo '\n' |  /root/wlcap.wlan.sh  > $FILE & 
