#!/bin/bash

cd $(dirname $0)

_help() {
    echo
    echo "$0 command [args...]"
    echo
    echo "commands:"
    echo "  add-remote  repo-name"
    echo "  push-remote repo-name"
    echo "  safe-dir"
    echo "  check"
    echo

    exit 1
}

[ ! $1 ] && _help

case "$1" in
    add-remote)
        [ ! $2 ] && _help
        cd $2
        git remote add gitee  git@gitee.com:evilbros/$2.git
        git remote add github git@github.com:evilbros/$2.git
        chown git:git config
        ;;

    push-remote)
        [ ! $2 ] && _help
        cd $2
        git push --all --follow-tags gitee
        git push --all --follow-tags github
        ;;

    safe-dir)
        git config --global --remove-section safe
        for x in $(find -maxdepth 1 -type d | grep -E '^./[^.]'); do
            dir=$(realpath $x)
            echo "safe dir: $dir"
            git config --global --add safe.directory $dir
        done
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
