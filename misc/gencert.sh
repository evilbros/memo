#!/bin/bash

[ ! $1 ] && echo "$0 name" && exit 1

fn=$1

mkdir -p ${fn}
openssl req -x509 -nodes -days 3650 -newkey rsa:2048 -keyout ${fn}/${fn}.key -out ${fn}/${fn}.cert
openssl pkcs12 -inkey ${fn}/${fn}.key -in ${fn}/${fn}.cert -export -out ${fn}/${fn}.pfx

echo "Done."
