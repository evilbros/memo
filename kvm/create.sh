#!/bin/bash

read -p "Are you sure?[Yes/No]" x
[ "$x" != "Yes" ] && exit 1

virt-install \
    --name centos7 \
    --os-type linux \
    --os-variant rhel7 \
    --vcpus 4 --cpu host \
    --memory 4096 \
    --network bridge=br0 \
    --disk path=/data/vms/base/centos7.img,size=200,sparse=yes \
    --graphics none \
    -l /data/vms/iso/CentOS-7-x86_64-Minimal-1511.iso \
    -x 'console=ttyS0'
