#!/bin/bash

INFO_ADDR='addr'

while true; do
    text="服Id    注册    在线\\n""$( \
        curl -sL $INFO_ADDR \
        | sed '1 i\x=' \
        | sed '$ a\console.log(x.data.sort((a,b)=>a.id-b.id).map(v=>`${v.id}      ${v.reg}      ${v.online}`).join(`\\\\n`))' \
        | node -)"

    ./send-feishu.sh "$text"

    sleep 2h
done
