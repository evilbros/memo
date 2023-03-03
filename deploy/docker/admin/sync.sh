#!/bin/bash

[ ! $2 ] && echo "$0 services... version" && exit 1

services=()
while [ $# -gt 1 ]; do
    services+=($1)
    shift
done
ver=$1

. prepare

# stats
syncs=()
removes=()
for svc in "${services[@]}"; do
    ! is_enabled $svc && echo "$svc is NOT enabled. skip" && continue
    is_created $svc && removes+=($svc)

    syncs+=($svc)
done

# stop/remove first
[ ${#removes[@]} -gt 0 ] && docker-compose rm --stop -f ${removes[@]}

# sync
for svc in "${syncs[@]}"; do
    docker pull $(sed -nE "/^[[:space:]]*${svc}:[[:space:]]*$/,/^[[:space:]]*image:/ s/image:(.*:).*/\1${ver}/ p" docker-compose.yml)
    if [ $(uname -s) == 'Linux' ]; then
        sed -i -E "/^[[:space:]]*${svc}:[[:space:]]*$/,/^[[:space:]]*image:/ s/(image:.*:).*/\1${ver}/" docker-compose.yml
    else
        sed -i '' -E "/^[[:space:]]*${svc}:[[:space:]]*$/,/^[[:space:]]*image:/ s/(image:.*:).*/\1${ver}/" docker-compose.yml
    fi
done

# start
./run.sh

# image prune
docker image prune -f

