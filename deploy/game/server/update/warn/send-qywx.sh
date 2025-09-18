#!/bin/bash

ADDR='bot-addr'

[ ! "$1" ] && echo "$0 text" && exit 1

curl -sL -H 'content-type: application/json' -d "
{
    \"msgtype\": \"markdown_v2\",
    \"markdown_v2\": {
        \"content\": \"# $1\"
    }
}
" "$ADDR" > /dev/null

