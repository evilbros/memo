#!/bin/bash

certbot certonly \
    --config-dir ./cert \
    --work-dir ./cert/tmp \
    --logs-dir ./cert/log \
    --manual \
    --preferred-challenges=dns \
    --manual-auth-hook ./add-txt.sh \
    --manual-cleanup-hook ./del-txt.sh \
    -d '*.xxx.com'
