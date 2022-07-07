@echo off

wsl -d ubuntu-18.04 -u root -- ip addr add 172.22.22.22/24 broadcast 172.22.22.255 dev eth0 label eth0:1
netsh interface ip add address "vEthernet (WSL)" 172.22.22.21/24

echo done
