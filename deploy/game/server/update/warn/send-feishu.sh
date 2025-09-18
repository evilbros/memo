#!/bin/bash

ADDR='bot-addr'

[ ! "$1" ] && echo "$0 text" && exit 1

curl -sL -H 'content-type: application/json' -d "
{
    \"msg_type\": \"text\",
    \"content\": {
        \"text\": \"$1\n<at user_id=\\\"all\\\">所有人</at>\"
    }
}
" "$ADDR" > /dev/null
