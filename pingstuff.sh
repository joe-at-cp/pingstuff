#!/bin/bash
# Joe Dillig - Check Point Software 2019
# What does this script do? It pings stuff clearly :)
# Usage:
# pingstuff.sh <Host1> <Host2> <Host3> and so on to oblivion
clear
echo "===================================[ Pinging $# Hosts ]==================================="
RESULTS="Host IP, Next Hop IP, Outbound Interface, ARP Entry, Result"
while true; 
do
    for HOST in "$@"
        do
            PING_RESULT=`ping -qc1 -W 1 $HOST 2>&1 | awk -F'/' 'END{ print (/^rtt/? "OK "$5" ms":"FAIL") }'`
            ROUTE_CHECK=`ip route get $HOST | grep dev | grep via`
            if [ "$ROUTE_CHECK" == "" ];
            then    
                #Destination host is on local network
                ROUTE_RESULT=`ip route get $HOST | grep dev | awk '{print $1", NA (Local), "$3","}'`
            else
                #Destination host requires next hop
                ROUTE_RESULT=`ip route get $HOST | grep dev | awk '{print $1", "$3", "$5","}'`
            fi
            ARP_RESULT=`arp -an | grep $HOST | awk '{print $4}'`
            if [ "$ARP_RESULT" == '' ]; then ARP_RESULT="NA" ;fi
            RESULTS=$RESULTS'\n'"$ROUTE_RESULT $ARP_RESULT, $PING_RESULT"
        done
clear
echo "===================================[ Pinging $# Hosts ]==================================="
echo -e $RESULTS | column -t -s ','
RESULTS="Host IP, Next Hop IP, Outbound Interface, ARP Entry, Result"
done
