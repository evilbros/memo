#!/bin/bash

cd $(dirname $0)

# prepare log file
LOG=./log_update.txt
TS=$(date +"%F %T")
echo -e "[$TS]\n---------------------" > $LOG

# query current IP
ipquery=(
    "curl -sL http://ip.gs"
    "curl -sL https://ipapi.co/ip"
    "curl -sL 'https://ip.cn/api/index?ip=&type=0' | sed -En '1 s/.*\"ip\"\s*:\s*\"([^\"]*)\".*/\1/p'"
    "curl -sL http://ip-api.com/line/?fields=query"
)
for cmd in "${ipquery[@]}"; do
    ip=$(bash -c "$cmd")
    if [ $ip ]; then
        echo "$cmd [OK]" >> $LOG
        break
    fi
done
[ ! $ip ] && echo "query ip failed" >> $LOG && exit 1
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
