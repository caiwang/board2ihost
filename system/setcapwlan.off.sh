#script to bring down wlcap on wlan
#!/bin/sh
#use ramdisk
dirBASE='/run/shm'
#use sd card
#dirBASE='/wms'

#mysql  passwd
mysqlPASS='0ffs4t?'

# check wlcap output file size to determine sleep time
# default sleep time
timeSLEEP=55
# default minimum wlcap output file size
minSIZE=1024
# when wlcap works with ruckus, a lager minSIZE is set
if [  -f /root/ruckus  ]; then
    minSIZE=4096
fi

mkdir -p $dirBASE/pkt/wlan

# retrive $wlFILE (set by 'setcapwlan.on.sh)
if [ -f $dirBASE/pkt/wlan/.workingfile ]; then
    source $dirBASE/pkt/wlan/.workingfile
fi

# get wlcap ooutput file size
fSIZE=0
if [ "-$wlFILE" != '-' -a -f $wlFILE  ]; then
    fSIZE=$(wc -c "$wlFILE" | cut -f 1 -d ' ')
fi
# when wlcap works with ruckus and output a small-sized file
if [ -f /root/ruckus -a  $fSIZE -lt $minSIZE ]; then
    # give less sleep time, leave time to restart ruckus rpcap
    timeSLEEP=30
fi
#echo $timeSLEEP, $wlFILE, $fSIZE
#let wlcap works a little more and then kill it
if [ ! -n "$1" ]; then
#    echo "sleep : "$timeSLEEP
    sleep $timeSLEEP
fi

killall wlcap &

#echo 'wlFILE : '$wlFILE
if [ "-$wlFILE" != '-' -a -f $wlFILE  ]; then
    outFILE=$wlFILE'.out'
    #line start with 0x only; replace 1st ",," to ",".  ',' as splitter make column; get column 2,3(substring),5,6; merge lines by the 1st&2nd column
    cat $wlFILE | sed -e '/^0x/!d;s/,,/,/1' | awk -F, 'BEGIN { OFS=","}{print $2, $3 = substr($3, 1, length($3)-11)"0", $5,$6}' | awk -F',' '{a[$1","$2] = a[$1","$2]","$3"^"$4}END{for(i in a){print i""a[i]}}' | sed 's/,/|/3g;s/\^|/|/g;s/\^$//' > $outFILE
    
    mysql -uroot -p$mysqlPASS wms<<EOFMYSQL
      LOAD DATA INFILE "$outFILE" INTO TABLE 802_11_packet
      FIELDS TERMINATED BY ','
      LINES TERMINATED BY '\n'
      (mac,pkttime,pktsignal);
EOFMYSQL
#!!! CAUTION: NO space before 'EOFMYSQL' !!!

    echo 'update 802_11_packet set create_t=now() where create_t is NULL' | mysql -uroot -p$mysqlPASS wms
    
    # remove files
    if [ ! -n "$2" ]; then
        rm $wlFILE
        rm $outFILE
        echo "remove files"
    fi

fi

if [ $fSIZE -lt $minSIZE ]; then
    if [ -f /root/ruckus ]; then
        bash /root/setruckus.sh 
    else
        iw dev mon.ihost del 
        iw dev wlan0 interface add mon.ihost type monitor 
        ip link set mon.ihost promisc on 
        ifconfig mon.ihost up 
    fi
fi

