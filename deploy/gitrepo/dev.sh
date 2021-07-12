#!/bin/bash

cd $(dirname $0)

_help() {
    echo
    echo "$0 command [args...]"
    echo
    echo "commands:"
    echo "  add-remote  repo-name"
    echo "  push-remote repo-name"
    echo "  check"
    echo

    exit 1
}

[ ! $1 ] && _help

case "$1" in
    add-remote)
        [ ! $2 ] && _help
        cd $2
        git remote add github git@github.com:evilbros/$2.git
        chown git:git config
        ;;

    push-remote)
        [ ! $2 ] && _help
        cd $2
        git push --all --follow-tags github
        ;;

    check)
        for x in $(find -maxdepth 1 -type d | grep -E '^./[^.]'); do
            echo '================'
            echo $x
            cd $x
            git fsck
            cd - > /dev/null
        done
        ;;

    *)
        _help
esac
