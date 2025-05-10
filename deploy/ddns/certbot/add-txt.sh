#!/bin/bash

DOMAIN=$CERTBOT_DOMAIN
VALIDATION=$CERTBOT_VALIDATION

full=_acme-challenge.$DOMAIN
subname=${full%.xxx.com}

./dnspod.js create $subname TXT $VALIDATION

while true; do
    C=$(dig $full TXT | grep -v ';')
    [ "$C" ] && break
    sleep 5s
done
sleep 10m
