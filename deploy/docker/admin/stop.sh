#!/bin/bash

[ ! $1 ] && echo "$0 services..." && exit 1

. prepare

echo -e "stopping services...\n"

services=()
for svc in "$@"; do
    ! is_enabled $svc && echo "$svc is NOT enabled. skip" && continue
    ! is_created $svc && continue
    services+=($svc)
done

[ ${#services[@]} -gt 0 ] && docker-compose stop ${services[@]}

