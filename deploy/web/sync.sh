#!/bin/bash

cd $(dirname $0)

#########################################
# name & arg
projects=(
    "pushbox        play"
    "tinydraw"
    "neatapp"
)
#########################################

[ ! $1 ] && echo "$0 name" && exit 1

# check name
found=0
for p in "${projects[@]}"; do
    name=${p%% *}
    arg=${p##* }

    if [ $1 == $name ]; then
        found=1
        break
    fi
done

[ $found -eq 0 ] && echo "invalid name" && exit 1

# deploy
DIR=$(mktemp -d $name.XXXX)
cd $DIR

git clone ssh://git@192.168.0.200:1818/~git/$name
cd $name

rm -rf package.json package-lock.json
./dev.sh build $arg
tarfile=$(./dev.sh tar $arg)

rm -rf ../../../game/$name
mkdir -p ../../../game/$name
tar -C ../../../game/$name -xf $tarfile

cd ../..
rm -rf $DIR

# done
echo "$name deployed successfully"
