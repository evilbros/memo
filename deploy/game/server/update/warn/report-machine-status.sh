#!/bin/bash

######################################################

get_resources() {
    ip=$1
    ssh $ip "
        mem=\$(free -h | grep Mem | awk '{print \$7}')
        disk=\$(df -h | grep data | awk '{print \$4}')
        load=\$(cat /proc/loadavg | awk '{print \$1\"|\"\$2\"|\"\$3}')

        printf '%-7s%-10s%-10s%-15s\n' $ip \$mem \$disk \$load
    "
}

export -f get_resources

######################################################

while true; do
    # stats machine server count
    svr_count=$(
        cd ..
        ./admin.sh list-folders | awk '{print $2}' | sort | uniq -c | awk '{printf "%-7s%-7s\n", $2, $1}'
    )

    # stats machine memory
    svr_mem=$(
        [ -f ../SERVER_MACHINES ] && . ../SERVER_MACHINES
        echo "${SERVER_MACHINES[@]}" | xargs -n 1 -P 25 bash -c 'get_resources $1' _ | sort -k1.2 -n
    )

    # make text
    text=$(
        cat <<EOF
机器  服务器数量
--------------------
$svr_count

机器  可用内存   剩余磁盘  负载(1/5/15min)
-----------------------------------------
$svr_mem
EOF
)

    ./send-feishu.sh "${text//$'\n'/\\n}"

    sleep 2h
done
