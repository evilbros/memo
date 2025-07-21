#!/bin/bash

cd $(dirname $0)

IP_QUERY=(
    "curl -m 15 -sL http://ipinfo.io/ip"
    "curl -m 15 -sL http://ip-api.com/line/?fields=query"
    "curl -m 15 -sL http://ip.gs"
    "curl -m 15 -sL https://ipapi.co/ip"
    "curl -m 15 -sL https://api.ipapi.is/ip"
)

LOG=./log_update.txt

while true; do
    while true; do
        TS=$(date +"%F %T")
        echo -e "[$TS]\n---------------------" > $LOG

        # query current IP
        for cmd in "${IP_QUERY[@]}"; do
            ip=$(bash -c "$cmd")
            if [ $ip ]; then
                echo "$cmd [OK]" >> $LOG
                break
            fi
        done
        [ ! $ip ] && echo "query ip failed" >> $LOG && break
        echo "query current ip: $ip" >> $LOG

        # check last IP
        [ ! -f last ] && touch last
        last_ip=$(<last)
        echo "query last ip: $last_ip" >> $LOG

        if [ "$ip" == "$last_ip" ]; then
            echo "ip NOT changed. do nothing" >> $LOG
            break
        fi

        # update
        ./dnspod.js update $ip &>> $LOG
        [ $? -ne 0 ] && break

        # ok
        echo $ip > last

        break
    done

    sleep 15m
done

