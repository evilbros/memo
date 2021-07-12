#!/bin/bash

cd $(dirname $0)

# prepare log file
LOG=./log_update.txt
TS=$(date +"%F %T")
echo -e "[$TS]\n---------------------" > $LOG

# query current IP
#ip=$(curl -sL http://ip.gs)
ip=$(curl -sL http://ip-api.com/line/?fields=query)
echo "query current ip: $ip" >> $LOG

# check last IP
[ ! -f last ] && touch last
last_ip=$(<last)
echo "query last ip: $last_ip" >> $LOG

if [ "$ip" == "$last_ip" ]; then
    echo "ip NOT changed. exit" >> $LOG
    exit 1
fi

# update
./dnspod.js update $ip &>> $LOG
[ $? -ne 0 ] && exit 1

# ok
echo $ip > last
