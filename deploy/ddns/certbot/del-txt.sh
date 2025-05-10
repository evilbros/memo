#!/bin/bash

DOMAIN=$CERTBOT_DOMAIN
VALIDATION=$CERTBOT_VALIDATION

full=_acme-challenge.$DOMAIN
subname=${full%.xxx.com}

txtRecordId=$(./dnspod.js list TXT | grep RecordId | grep -Po '\d+')
./dnspod.js delete $txtRecordId
