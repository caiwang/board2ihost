#!/bin/sh
netcap -l -i wlan0 -T fields -E separator=, -e eth.type -e eth.src -e frame.time_epoch -e ip.src -e ip.dst -e http.request.full_uri -f "(src net 172.16.0.0/16) and (not (dst net 172.16.0.0/16)) and (dst port http or 8080 or https) and ((tcp-syn)!=0) and (not ether src 48:d2:24:5f:f4:17)"
