#!/bin/bash

cd $(dirname $0)

LOG=./log_autopush.txt

while true; do
    TS=$(date +"%F %T")
    echo -e "[$TS]\n---------------------" > $LOG

    for name in $(find -maxdepth 1 -type d | grep -E '^./[^.]'); do
        name=${name#./}
        echo "pushing $name" >> $LOG
        ./dev.sh push-remote $name &>> $LOG
        echo "" >> $LOG
    done

    sleep 2h
done

