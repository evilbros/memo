#!/bin/bash

ulimit -S -c unlimited > /dev/null 2>&1
ulimit -SH -n 65535

PROGRAM="hyperlinker"
WORK_PATH=$(realpath $(dirname $0))
SERVER_STATUS_FILE="${WORK_PATH}/server_status"
START_WAIT_SEC=600
KILL_WAIT_SEC=600

SERVER_LIST=(
    "info"
    "center"
    "transit"
    "platform 100"
    "record"
    "logic"
    "gate"
)

function clear_status_file() {
    cat /dev/null > $SERVER_STATUS_FILE
}

function get_cmdline() {
    for svr in "${SERVER_LIST[@]}"; do
        if [ "$*" == "$svr" ]; then
            echo "$WORK_PATH/$PROGRAM -$@"
            return 0
        fi
    done

    return 1
}

function is_process_running() {
    local cmdline=$1
    ps ux | grep -w "$cmdline" | grep -v grep > /dev/null
}

function check_started() {
    local flag_name=$1
    local sec=$START_WAIT_SEC

    while [ $sec -gt 0 ]; do
        sleep 1
        grep -w $flag_name $SERVER_STATUS_FILE > /dev/null
        [ $? -eq 0 ] && return 0

        let sec--
    done

    return 1
}

function check_stopped() {
	local cmdline=$1
    local sec=$KILL_WAIT_SEC

    while [ $sec -gt 0 ]; do
        sleep 1
        is_process_running "$cmdline"
        [ $? -ne 0 ] && return 0

        let sec--
    done

    return 1
}

function start() {
    cmdline=$(get_cmdline $@)
    [ $? -ne 0 ] && echo "invalid server: $@" && return 1

    is_process_running "$cmdline"
    [ $? -eq 0 ] && echo "$@ is already running" && return 1

    echo -n "starting $@...   "
    nohup $WORK_PATH/$PROGRAM -$@ 2>./$1.err 1>/dev/null &

    local start_flag
    if [ $2 ]; then
        start_flag="$1_$2_started"
    else
        start_flag="$1_started"
    fi

    check_started $start_flag
    if [ $? -eq 0 ]; then
        echo -e "\033[32mOK\033[0m"
        return 0
    else
        echo -e "\033[31mFailed\033[0m"
        return 1
    fi
}

function stop() {
    cmdline=$(get_cmdline $@)
    [ $? -ne 0 ] && echo "invalid server: $@" && return 1

    echo -n "stopping $@...   "
	local pid=$(ps ux | grep -w "$cmdline" | grep -v grep | awk '{print $2}')
	[ $pid ] && kill $pid

    check_stopped "$cmdline"
    if [ $? -eq 0 ]; then
        echo -e "\033[32mStopped\033[0m"
        return 0
    else
        echo -e "\033[31mFailed\033[0m"
        return 1
    fi
}

function show_cmd() {
	echo "[status]                          : show all the servers status."

	echo "[start] [server_name] [args...]   : start the logic server and the gate server."
	echo "[stop] [server_name] [args...]    : stop the logic server and the gate server."

    echo "[start_all]                       : start all servers in test env."
    echo "[stop_all]                        : stop all servers in test env."
}   


cmd=$1
shift

clear_status_file

case "$cmd" in
    start)
        start $@
        ;;

    stop)
        stop $@
        ;;

    start_all)
        for svr in "${SERVER_LIST[@]}"; do
            start $svr
        done
        ;;

    stop_all)
        for ((i = ${#SERVER_LIST[@]} - 1; i >= 0; i--)); do
            svr=${SERVER_LIST[i]}
            stop $svr
        done
        ;;

    status)
        ps ux | grep -w "$WORK_PATH" | grep -v grep
        ;;

    *)
        show_cmd
        ;;
esac
