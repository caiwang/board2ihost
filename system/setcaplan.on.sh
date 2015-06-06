#script to bring up wlcap.lan.sh

#!/bin/sh
#use ramdisk
dirBASE='/run/shm'
#use sd card
#dirBASE='/wms'

mkdir -p $dirBASE/pkt/lan

NOW=$(date +"%F")
NOWT=$(date +"%T")
minNOWT=$(echo $NOWT | sed 's/://g;s/..$//')

FILE="$dirBASE/pkt/lan/$NOW-$minNOWT"

echo "lanFILE=$FILE" > $dirBASE/pkt/lan/.workingfile
echo '\n' |  /root/wlcap.lan.sh  > $FILE & 
