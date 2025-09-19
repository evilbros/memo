#!/bin/bash

INFO_ADDR='http://127.0.0.1:18800/get_server_player_count'

while true; do
    text="服Id    注册    在线\\n""$( \
        curl -s $INFO_ADDR \
        | sed '1 i\x=' \
        | sed '$ a\console.log(x.data.sort((a,b)=>a.id-b.id).map(v=>`${v.id}      ${v.reg}      ${v.online}`).join(`\\\\n`))' \
        | node -)"

    ./send-feishu.sh "$text"

    sleep 2h
done
