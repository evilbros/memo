#!/bin/bash

name=$1
size=$2

[ ! $size ] && echo "$0 name size" && exit 1

qemu-img create -f qcow2 -o size=$size,lazy_refcounts=on ./img/disks/$name.img

echo "disk file created: ./img/disks/$name.img"
