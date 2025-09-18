#!/bin/bash

WORK_DIR=$(realpath $(dirname $0))

[ ! $1 ] && echo "$0 ips..." && exit 1

cd $WORK_DIR
for ip in $*; do
    echo "----------- $ip -----------"

    # check and prepare
    ssh $ip '
        [ -d /data/server ] && exit 1
        sudo chown 1000:1000 /data -R
        rm -rf /data/*
        mkdir -p /data/server/update
    '
    [ $? -ne 0 ] && echo "already initialized" && continue

    # copy files
    scp *.tar.gz $ip:/data

    cd /data/server/update
    scp -r *.sh files config warn *.tar.gz $ip:/data/server/update
    cd $WORK_DIR

    scp -r ./server $ip:/data

    ssh $ip '
        cd /data
        for fn in *.tar.gz; do
            tar -xf $fn
        done
        rm *.tar.gz

        cd /data/server/update
        rm admin.sh auto-open-by-reg.sh time-open.sh ./warn/report-* ./warn/*warn-api* ./warn/show.sh

        cd /data/db
        ./init_passwd.sh
    '
done

