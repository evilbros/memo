#!/bin/bash

. prepare

echo -e "checking service list...\n"

# remove
removes=()
for svc in "${created[@]}"; do
    if ! is_enabled $svc; then
        removes+=($svc)
    fi
done
[ ${#removes[@]} -gt 0 ] && docker-compose rm --stop -f ${removes[@]}

# add
adds=()
for svc in "${enabled[@]}"; do
    adds+=($svc)
done
[ ${#adds[@]} -gt 0 ] && docker-compose up -d ${adds[@]}

