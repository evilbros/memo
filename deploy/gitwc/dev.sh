#!/bin/bash

cd $(dirname $0)

_help() {
    echo
    echo "$0 command [args...]"
    echo
    echo "commands:"
    echo "  update"
    echo "  backup"
    echo

    exit 1
}

[ ! $1 ] && _help

case "$1" in
    update)
        for x in $(find -maxdepth 1 -type d | grep -E '^./[^.]'); do
            echo '================'
            echo $x
            cd $x
            git pull
            cd - > /dev/null
        done
        ;;

    backup)
        mkdir -p _XXX

        for x in $(find -maxdepth 1 -type d | grep -E '^./[^._]'); do
            [ "$x" == "./blog" ] && continue

            echo '================'
            echo $x

            cp -r $x _XXX/
            cd _XXX
            x=$(basename $x)
            rm $x/.git $x/bin -rf
            rm $(find $x -type d -name node_modules) -rf
            tar -czf $x.tar.gz $x
            rm $x -rf
            cd - > /dev/null
        done
        ;;

    *)
        _help
esac
