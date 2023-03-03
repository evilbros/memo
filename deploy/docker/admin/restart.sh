#!/bin/bash

[ ! $1 ] && echo "$0 services..." && exit 1

. prepare

echo -e "restarting services...\n"

services=()
for svc in "$@"; do
    ! is_enabled $svc && echo "$svc is NOT enabled. skip" && continue
    ! is_created $svc && need_start=true && continue
    services+=($svc)
done

[ ${#services[@]} -gt 0 ] && docker-compose restart ${services[*]}
[ $need_start ] && ./run.sh

