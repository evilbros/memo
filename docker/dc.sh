#!/bin/bash

[ ! "$2" ] && echo "$0 yml-file <up|down|restart> [service ...]" && exit 1

fn=$1
cmd=$2
shift;shift
svc=$@

case $cmd in
    up)
        docker-compose -f $fn -p ${fn%.yml} up -d $svc
        ;;
    
    down)
        docker-compose -f $fn -p ${fn%.yml} down $svc
        ;;
    
    restart)
        docker-compose -f $fn -p ${fn%.yml} restart $svc
        ;;
esac

