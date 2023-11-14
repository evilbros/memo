#!/bin/bash

[ -x /init.sh ] && /init.sh

exec /usr/sbin/sshd -D

