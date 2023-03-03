@echo off

c:

@echo starting wsl
wsl -u root -- mkdir -p /data

@echo adding IPs
wsl -u root -- ip addr add 172.22.22.22/24 broadcast 172.22.22.255 dev eth0 label eth0:1
netsh interface ip add address "vEthernet (WSL)" 172.22.22.21/24

@echo attaching vhd
wsl --mount --vhd --bare D:\work\work.vhdx

@echo mounting vhd AND starting docker
wsl -u root -- bash -c "D=\$(lsblk | grep 300G | cut -d' ' -f1); if ! df -h | grep /dev/\$D; then mount /dev/\$D /data; if which nginx; then service nginx start; fi fi"

pause
