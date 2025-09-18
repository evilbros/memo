#!/bin/bash

cd $(dirname $0)
confdir=$(pwd)/config

[ ! $1 ] && echo "$0 serverid" && exit 1
[ ! -f STEP_SERVER ] && echo "file STEP_SERVER not found" && exit 1

# args
id=$1
name=s$id

# ask
read -p "Are you sure to open new server $name ? [Yes/No]" x
[ "$x" != "Yes" ] && exit 1

# check server id
if ((id < 1)) || ((id > 9999)); then
    echo "server id range should be [1, 9999]"
    exit 1
fi

# already opened ?
if grep -w $name STEP_SERVER > /dev/null; then
    echo "$name already opened"
    exit 1
fi

# check server folder
[ -d ../game/$name ] && echo "server folder already exists" && exit 1

# get server count
svr_count=$(grep logic STEP_SERVER | wc -l)
if ((svr_count >= 99)); then
    echo "no more server can be opened on this machine"
    exit 1
fi

# find a new port
[ ! -f ./PORTS ] && touch ./PORTS
port_list=($(echo $(<PORTS) | tr ' ' '\n' | sort -n))

for ((i = 0; i < 99; i++)); do
    if ((port_list[i] != i + 1)); then
        portid=$((i + 1))
        port_list=("${port_list[@]:0:i}" "$portid" "${port_list[@]:i}")
        printf "%s\n" "${port_list[@]}" > ./PORTS
        break
    fi
done

[ ! $portid ] && echo "no available port found" && exit 1

# create server folder
gate_port=$((18600 + portid))
logic_port=$((18500 + portid))
record_port=$((18400 + portid))

cp $confdir/Server_tpl.cfg $confdir/Server${id}.cfg
sed -i \
    -e "s/ServerID=1/ServerID=${id}/g" \
    -e "s/ExternalGatePort=18601/ExternalGatePort=${gate_port}/g" \
    -e "s/LogicPort=18501/LogicPort=${logic_port}/g" \
    -e "s/RecordPort=18401/RecordPort=${record_port}/g" \
    -e "s/=HyperLinker1/=HyperLinker${id}/g" \
    $confdir/Server${id}.cfg

mkdir -p ../game/s${id}/config
ln -sf $confdir/Server${id}.cfg ../game/s${id}/config/Server.cfg

# append STEP_SERVER
sed -i "\$ c\    \"$name        record,logic,gate\"\n)" STEP_SERVER

# update contents
./sg.sh update $name

# start server
./sg.sh start $name

# show info
echo "@Info@ $name $gate_port"

# report
[ -x ./warn/send-feishu.sh ] && ./warn/send-feishu.sh "\n🎉🎆🌻🌞🎇  $id 服开了\n"


