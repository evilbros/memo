#!/bin/bash

ADDR='bot-addr'

[ ! "$1" ] && echo "$0 text" && exit 1

curl -s --max-time 15 -H 'content-type: application/json' -d "
{
    \"msgtype\": \"text\",
    \"text\": {
        \"content\": \"$1\"
    },
    \"at\": {
        \"isAtAll\": true,
    }
}
" "$ADDR" > /dev/null
