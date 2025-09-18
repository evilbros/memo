#!/bin/bash

# 每台机器的控制脚本

######################################################

PROGRAM=hyperlinker
UPDATE_DIR=$(realpath $(dirname $0))
GAME_DIR=$(realpath $UPDATE_DIR/../game)
COMBAT_DIR=$(realpath $UPDATE_DIR/../combat)

######################################################

STEP_LIST=(
    STEP_CENTER
    STEP_SERVER
)

STEP_CENTER=(
    # folder               server-list
    "center         info,center,transit,platform 100"
)

STEP_SERVER=(
    "s1        record,logic,gate"
)

######################################################

for step in "${STEP_LIST[@]}"; do
    [ -f $step ] && . $step
done

######################################################

contains() {
    local v=$1
    shift
    local lst=$@

    for e in $lst; do
        [ "$e" == "$v" ] && return 0
    done
    return 1
}

# get all folders except those in the args
get_all_folders() {
    local except=$@

    local folders
    for step in "${STEP_LIST[@]}"; do
        step="${step}[@]"

        for row in "${!step}"; do
            local folder=${row%% *}
            contains $folder $except && continue
            folders+="$folder "
        done
    done
    echo "$folders"
}

start() {
    for step in "${STEP_LIST[@]}"; do
        step="${step}[@]"

        local lines=''
        for row in "${!step}"; do
            local folder=${row%% *}
            ! contains $folder $@ && continue

            lines+="\"$row\""$'\n'
        done
        [ ! "$lines" ] && continue

        xargs -P 25 -L 1 bash -c 'start_folder "$*"' _ <<-EOF
            $lines
EOF
    done
}

start_folder() {
    local row=$1
    local folder=${row%% *}
    local svrlist=$(echo $row | cut -d' ' -f2-)

    echo "starting folder $folder ..."

    IFS=, read -a servers <<< "$svrlist"

    cd $GAME_DIR/$folder
    for svr in "${servers[@]}"; do
        ./server.sh start $svr
    done
}

stop() {
    for ((i = ${#STEP_LIST[@]} - 1; i >= 0; i--)); do
        step="${STEP_LIST[i]}[@]"

        local lines=''
        for row in "${!step}"; do
            local folder=${row%% *}
            ! contains $folder $@ && continue

            lines+="\"$row\""$'\n'
        done
        [ ! "$lines" ] && continue

        xargs -P 25 -L 1 bash -c 'stop_folder "$*"' _ <<-EOF
            $lines
EOF
    done
}

stop_folder() {
    local row=$1
    local folder=${row%% *}
    local svrlist=$(echo $row | cut -d' ' -f2-)

    echo "stopping folder $folder ..."

    IFS=, read -a servers <<< "$svrlist"

    cd $GAME_DIR/$folder
    for ((i = ${#servers[@]} - 1; i >= 0; i--)); do
        ./server.sh stop ${servers[i]}
    done
}

update_combat() {
    echo "killing combat ..."
    pid=`ps ux | grep -w "dotnet $COMBAT_DIR/CombatServer.dll" | grep -v grep | awk '{print $2}'`
    [ $pid ] && kill $pid
    sleep 1

    cd $COMBAT_DIR
    rm *.dll *.pdb *.json rof skill_data -rf

    cd $UPDATE_DIR/combat/bin
    cp -r *.dll *.pdb *.json rof skill_data $COMBAT_DIR

    echo "starting combat..."
    cd $COMBAT_DIR
    nohup dotnet $COMBAT_DIR/CombatServer.dll 2>combat.err 1>/dev/null &
    echo 'combat server updated'
}

update_configs() {
    echo "updating configs ..."

    for folder in $(get_all_folders); do
        ! contains $folder $@ && continue
        cd $GAME_DIR/$folder/config
        cp -sf `find $UPDATE_DIR/config/ -type f ! -name 'Server*'` .
    done
}

update() {
    for folder in $(get_all_folders); do
        ! contains $folder $@ && continue

        echo "updating folder contents: $folder"

        cd $GAME_DIR/$folder
        rm -rf $PROGRAM rofs HexagonMapData MaskWord.txt
        cd $UPDATE_DIR/server/bin
        cp -r $PROGRAM rofs HexagonMapData MaskWord.txt $GAME_DIR/$folder
    done

    update_configs $@
}

unpack_server() {
    cd $UPDATE_DIR
    rm server -rf
    mkdir server
    tar -C server -xf server.tar.gz
}

unpack_combat() {
    cd $UPDATE_DIR
    rm combat -rf
    mkdir combat
    tar -C combat -xf combat.tar.gz
}

copy_core_files() {
    cd $UPDATE_DIR/files
    for folder in $(get_all_folders); do
        ! contains $folder $@ && continue
        cp * $GAME_DIR/$folder
    done
}

status() {
    for folder in $(get_all_folders); do
        ! contains $folder $@ && continue

        cd $GAME_DIR/$folder
        ./server.sh status
    done
}

######################################################

export GAME_DIR
export -f start_folder
export -f stop_folder

######################################################

cmd=$1
shift
folders=$@

if [ ! "$folders" ]; then
    folders=$(get_all_folders)
fi

case "$cmd" in
    get-all-folders)
        get_all_folders
        ;;

    start)
        start $folders
        ;;

    stop)
        stop $folders
        ;;

    start-except)
        start $(get_all_folders $folders)
        ;;

    stop-except)
        stop $(get_all_folders $folders)
        ;;

    update)
        unpack_server
        copy_core_files $folders
        update $folders
        ;;

    upstart)
        unpack_server
        copy_core_files $folders
        stop $folders
        update $folders
        start $folders
        ;;

    status)
        status $folders
        ;;

    update-combat)
        unpack_combat
        update_combat
        ;;

    *)
        echo "$0 get-all-folders"
        echo "$0 start|stop|start-except|stop-except|update|upstart|status [folders...]"
        echo "$0 update-combat"
esac
