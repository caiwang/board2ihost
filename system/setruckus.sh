#script to set Ruckus AP Capture

#!/bin/sh

if [ -f /root/ruckus ]; then
    REMOTE_IP=`sed '1q;d' /root/ruckus`
    PINGFLAG=`ping -c 2 $REMOTE_IP  | grep "ttl=[0-9]\+"`
    PINGCNT=0
    while [ "-$PINGFLAG" = "-" -a $PINGCNT -lt 6 ]
    do
        sleep 20
        PINGFLAG=`ping -c 2 $REMOTE_IP  | grep "ttl=[0-9]\+"`
        PINGCNT=$[$PINGCNT+1]
    done
    
    if [ $PINGCNT -lt 6 ];then
        echo 'Set RUCKUS AP capture....'
        /root/setruckus.exp
    else
        echo 'ERROR! CHECK CONNECTION TO RUCKUS AP '$REMOTE_IP
    fi
fi

