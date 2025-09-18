#!/bin/bash

[ ! "$1" ] && echo "$0 time" && exit 1

read -p 'set auto open server at specific time ? [Yes/No]' x
[ "$x" != "Yes" ] && exit 1


echo "bash -c './admin.sh open-new <<< Yes >> auto-time.log'" | at $@

