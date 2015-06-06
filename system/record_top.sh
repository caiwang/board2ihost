while :; do

    echo "=============================" >> /wms/top.txt
    date >> /wms/top.txt
    echo "-----------------------------" >> /wms/top.txt
    top -n 1 -b | head -15 >> /wms/top.txt
    echo "-----------------------------" >> /wms/top.txt
    chilli_query list >> /wms/top.txt
    sleep 60

done

