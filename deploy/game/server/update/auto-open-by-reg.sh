#!/bin/bash

cd $(dirname $0)

read -p 'this script will auto open new servers based on player registers. are you sure to run? [Yes/No]' x
[ "$x" != "Yes" ] && exit 1

INFO_ADDR='http://127.0.0.1:18800/get_server_player_count'
REG_TO_OPEN=1200

while true; do
    while true; do
        HM=$(date +%H%M)
        [[ $HM > 0029 && $HM < 0211 ]] && break

        max_svrid=$(./admin.sh get-max-serverid)
        next_svrid=$((max_svrid + 1))

        reg=$(
            curl -s $INFO_ADDR?serverid=$max_svrid |
            sed -e '1 i\x=' -e '$ a\console.log(x.data.length > 0 ? x.data[0].reg : 0)' |
            node -
        )
        [ $? -ne 0 ] && break

        ((reg < REG_TO_OPEN)) && break

        # get min load machine for the new server
        ip=$(./admin.sh get-min-load-machine)
        [ ! $ip ] && break

        # open new
        sleep 15
        echo "max_svrid=$max_svrid, reg=$reg => opening new server s$next_svrid on $ip"
        setsid ./admin.sh open-new $ip $next_svrid <<< Yes
        break
    done

    sleep 60
done
