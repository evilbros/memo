#!/bin/bash

base=$1
new=$2

[ ! $new ] && echo "$0 base new" && exit 1

virt-clone -o $base -n $new -f ./img/$new.img
virsh autostart $new

echo "new vm $new is cloned from $base"
