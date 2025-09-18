#!/bin/bash

# 整个游戏所有机器部署的总控制脚本
# 主要是通过在各个机器上调用 sg.sh 来实现的

######################################################

UPDATE_DIR=$(realpath $(dirname $0))
ROOT_DIR=$(realpath $UPDATE_DIR/../..)

######################################################

MACHINE_LIST=(
)

SERVER_MACHINES=(
)

BATTLE_MACHINES=(
)

######################################################

[ -f MACHINE_LIST ] && . MACHINE_LIST
[ -f SERVER_MACHINES ] && . SERVER_MACHINES
[ -f BATTLE_MACHINES ] && . BATTLE_MACHINES

######################################################

get_machine_ips() {
    for v in "${MACHINE_LIST[@]}"; do
        echo $v
    done
}

######################################################

dist() {
    dir=$(mktemp -d tmp.dist.XXX)
    cp *.tar.gz $dir

    cd $dir
    echo "${SERVER_MACHINES[@]}" | xargs -n 1 -P 25 bash -c "scp * \$*:$UPDATE_DIR" _
    cd ..
    rm -rf $dir
}

######################################################

declare -A FolderIp

list_folders() {
    echo "${SERVER_MACHINES[@]}" | xargs -n 1 -P 25 bash -c "list_folders_per_ip \$*" _
}

list_folders_per_ip() {
    ip=$1
    [ ! $ip ] && return 0

    for folder in $(ssh $ip "cd $UPDATE_DIR; ./sg.sh get-all-folders"); do
        echo "$folder $ip"
    done
}

build_folder_ip_index() {
    while read -r folder ip; do
        FolderIp[$folder]=$ip
    done <<< "$(list_folders)"
}

export UPDATE_DIR
export -f list_folders_per_ip

######################################################

make_folder_ip_list() {
    local lines=''
    for folder in $@; do
        ip=${FolderIp[$folder]}
        [ ! $ip ] && continue

        lines+="$folder $ip,"
    done
    echo $lines
}

exec_folder_cmd() {
    cmd=$1
    shift

    build_folder_ip_index
    make_folder_ip_list $@ | xargs -d, -n 1 -P 25 bash -c "exec_folder_cmd_single $cmd \$*" _
}

exec_folder_cmd_single() {
    cmd=$1
    folder=$2
    ip=$3
    [ ! $ip ] && return 0

    ssh $ip "cd $UPDATE_DIR; ./sg.sh $cmd $folder"
}

export -f exec_folder_cmd_single

######################################################

exec_machine_cmd() {
    machine_list="$1[@]"
    cmd=$2
    shift; shift

    echo "${!machine_list}" | xargs -n 1 -P 25 bash -c "exec_machine_cmd_single $cmd \$* $@" _
}

exec_machine_cmd_single() {
    cmd=$1
    ip=$2
    shift; shift
    [ ! $ip ] && return 0

    ssh $ip "cd $UPDATE_DIR; ./sg.sh $cmd $@"
}

export -f exec_machine_cmd_single

######################################################

stats_machine_load() {
    echo "${SERVER_MACHINES[@]}" | xargs -n 1 -P 25 bash -c "stats_machine_load_single \$*" _
}

stats_machine_load_single() {
    ip=$1
    [ ! $ip ] && return 0

    local n=0
    for folder in $(ssh $ip "cd $UPDATE_DIR; ./sg.sh get-all-folders"); do
        # exclude the machine NOT dedicated to game servers (starts with 's' and followed by a number)
        [[ ! $folder =~ ^s[0-9]+$ ]] && return 0

        ((n++))
    done
    echo "$ip $n"
}

get_min_load_machine() {
    local min_ip
    local min_n=999
    while read -r ip n; do
        if ((n < min_n)); then
            min_ip=$ip
            min_n=$n
        fi
    done <<< "$(stats_machine_load)"
    echo $min_ip
}

export -f stats_machine_load_single

######################################################

get_max_serverid() {
    local id=0

    while read -r folder ip; do
        [[ ! $folder =~ ^s([0-9]+)$ ]] && continue

        if ((${BASH_REMATCH[1]} > id)); then
            id=${BASH_REMATCH[1]}
        fi
    done <<< "$(list_folders)"

    echo $id
}

######################################################

open_new() {
    ip=$1
    id=$2

    max_id=$(get_max_serverid)

    [ ! $ip ] && ip=$(get_min_load_machine)
    [ ! $id ] && id=$((max_id + 1))

    # check serverid
    ((id <= max_id)) && echo "new serverid MUST > $max_id" && exit 1

    # sure ?
    read -p "Are you sure to open s$id on $ip ? [Yes/No]" x
    [ "$x" != "Yes" ] && exit 1

    # open new
    logfile=$(mktemp log.open.XXX)
    ssh $ip "cd $UPDATE_DIR; ./open-new.sh $id <<< Yes" | tee $logfile

    # notify
    wan_ip=$(get_machine_ips | grep -w "$ip" | awk '{print $3}')
    domain=$(get_machine_ips | grep -w "$ip" | awk '{print $4}')
    port=$(grep "@Info@ s$id" $logfile | awk '{print $3}')

    echo "notify: s$id $wan_ip $port $domain"

    # update server-list
    if [ -x ./cdn-scripts/ServerListUtil.py ]; then
        ./cdn-scripts/ServerListUtil.py add "S$id" $domain $port $id $id 1
        # HERE goes the command to refresh CDN
    fi

    # cleanup
    rm -rf $logfile
}

######################################################

whitelist() {
    [[ ! $1 =~ ^(set|update)$ ]] && ./admin.sh help && exit 1

    op=$1
    shift

    [ "$op" == "set" ] && printf "%s\n" $@ > /data/server/game/center/wlist.txt
    curl http://127.0.0.1:18801/reload_wlist
    echo
}

######################################################

reglimit() {
    [[ ! $1 =~ ^(update)$ ]] && ./admin.sh help && exit 1

    op=$1
    shift

    curl http://127.0.0.1:18801/reload_reglimit
    echo
}

######################################################

db_backup() {
    prefix=${1:-db}
    timestr=$(date +%Y-%m-%d_%H-%M)

    echo "${SERVER_MACHINES[@]}" | xargs -n 1 -P 25 bash -c "
        ssh \$* '
            cd $ROOT_DIR/db-backup
            ./backup.sh $prefix $timestr
        '
    " _
}

db_restore() {
    tarfile=$1

    [ ! "$tarfile" ] && ./admin.sh help && exit 1

    read -p "Are you sure to restore DB $tarfile ? [Yes/No]" x
    [ "$x" != "Yes" ] && exit 1

    read -p "Really ? [YES/No]" x
    [ "$x" != "YES" ] && exit 1

    echo "${SERVER_MACHINES[@]}" | xargs -n 1 -P 25 bash -c "
        ssh \$* '
            cd $ROOT_DIR/db-backup
            ./restore.sh $tarfile <<< Yes
        '
    " _
}

db_script() {
    scrfile=$1

    [ ! "$scrfile" ] && ./admin.sh help && exit 1

    read -p "Are you sure to execute db script $scrfile ? [Yes/No]" x
    [ "$x" != "Yes" ] && exit 1

    read -p "Really ? [YES/No]" x
    [ "$x" != "YES" ] && exit 1

    dbcmd=$(. ~/.bashrc; alias dbshell|sed -E $'s/^.*=\'| -p.*\'$//g')

    get_machine_ips | awk '{print $2}' | xargs -L 1 -P 25 bash -c "
        cd $UPDATE_DIR/db-scripts
        $dbcmd -p\$DB_PASS --host \$* --quiet $scrfile
    " _
}

merge-remove-servers() {
    ids=$@

    [ ! "$ids" ] && ./admin.sh help && exit 1

    read -p "Are you sure to do post merge operations ? [Yes/No]" x
    [ "$x" != "Yes" ] && exit 1

    echo "${SERVER_MACHINES[@]}" | xargs -n 1 -P 25 bash -c "
        ssh \$* '
            cd $UPDATE_DIR
            ./merge-remove-servers.sh $ids <<< Yes
        '
    " _
}

######################################################

cmd=$1
shift

case "$cmd" in
    dist)
        dist
        ;;

    list-folders)
        list_folders
        ;;

    get-min-load-machine)
        get_min_load_machine
        ;;

    get-max-serverid)
        get_max_serverid
        ;;

    start|stop)
        [ ! "$*" ] && ./admin.sh help && exit 1
        exec_folder_cmd $cmd $@
        ;;

    start-except|stop-except)
        [ ! "$*" ] && ./admin.sh help && exit 1
        exec_machine_cmd SERVER_MACHINES $cmd $@
        ;;

    update|status)
        if [ "$*" ]; then
            exec_folder_cmd $cmd $@
        else
            exec_machine_cmd SERVER_MACHINES $cmd
        fi
        ;;

    update-combat)
        exec_machine_cmd BATTLE_MACHINES $cmd
        ;;

    open-new)
        open_new $@
        ;;

    whitelist)
        whitelist $@
        ;;

    reglimit)
        reglimit $@
        ;;

    db-backup)
        db_backup $@
        ;;

    db-restore)
        db_restore $@
        ;;

    db-script)
        db_script $@
        ;;

    merge-remove-servers)
        merge-remove-servers $@
        ;;

    *)
        echo "$0 dist"
        echo "$0 list-folders|get-min-load-machine|get-max-serverid"
        echo "$0 start|stop|start-except|stop-except group-names..."
        echo "$0 update|status [group-names...]"
        echo "$0 update-combat"
        echo "$0 open-new [machine] [serverid]"
        echo "$0 whitelist set [IPs...]|update"
        echo "$0 reglimit update"
        echo "$0 db-backup [prefix]"
        echo "$0 db-restore tarfile"
        echo "$0 db-script scrfile"
        echo "$0 merge-remove-servers ids..."
esac
