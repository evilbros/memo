#!/bin/bash

cd $(dirname $0)

for x in $(find -maxdepth 1 -type d | grep -E '^./[^.]'); do
    echo '================'
    echo $x
    cd $x
    git pull
    cd - > /dev/null
done
