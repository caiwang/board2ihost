while :; do

    echo "=============================" >> /root/top.txt
    date >> /root/top.txt
    echo "-----------------------------" >> /root/top.txt
    top -n 1 -b | head -15 >> /root/top.txt
    echo "-----------------------------" >> /root/top.txt
    chilli_query list >> /root/top.txt
    sleep 60

done

