
#script to bring down netcap on lan
#!/bin/sh
#use ramdisk
dirBASE='/run/shm'
#use sd card
#dirBASE='/wms'

#mysql  passwd
mysqlPASS='0ffs4t?'

# default sleep time
timeSLEEP=55


mkdir -p $dirBASE/pkt/lan

# retrive $lanFILE (set by 'setcaplan.on.sh')
if [ -f $dirBASE/pkt/wlan/.workingfile ]; then
    source $dirBASE/pkt/lan/.workingfile
fi

#let netcap works a little more and then kill it
if [ ! -n "$1" ]; then
#    echo "sleep : "$timeSLEEP
    sleep $timeSLEEP
fi

killall netcap &

#echo 'lanFILE : '$lanFILE
if [ "-$lanFILE" != '-' -a -f $lanFILE  ]; then
    outFILE=$lanFILE'.out'
    #line start with 0x only;  ',' as splitter make column; get column 2,3(substring),4,5,6; merge lines by the 1st 2nd 3rd 4th column; replace ',' with '|' from the 5th occurence; collapse-repeating '|' in the last field; replace ',|' with ','; remove '|' at the end
    cat $lanFILE | sed -e '/^0x/!d' | awk -F, 'BEGIN { OFS=","}{print $2, $3 = substr($3, 1, length($3)-12)"00", $4,$5,$6}' | awk -F',' '{a[$1","$2","$3","$4] = a[$1","$2","$3","$4]","$5}END{for(i in a){print i""a[i]}}' | sed 's/,/|/5g' | tr -s '|'  | sed 's/,|/,/g;s/|$//;s/ //g'  > $outFILE
    
    mysql -uroot -p$mysqlPASS wms<<EOFMYSQL
      LOAD DATA INFILE "$outFILE" INTO TABLE eth_packet
      FIELDS TERMINATED BY ','
      LINES TERMINATED BY '\n'
      (mac,pkttime,srcip,destip,uri);
EOFMYSQL
#!!! CAUTION: NO space before 'EOFMYSQL' !!!

    echo 'update eth_packet set create_t=now() where create_t is NULL' | mysql -uroot -p$mysqlPASS wms
    
    # remove files
    if [ ! -n "$2" ]; then
        rm $lanFILE
        rm $outFILE
        echo "remove files"
    fi

fi




