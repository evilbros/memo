@echo off

%1 start "" mshta vbscript:createobject("shell.application").shellexecute("""%~0""","::",,"runas",1)(window.close)&exit

c:

@echo adding IPs
wsl -- sudo ip addr add 172.22.22.22/24 broadcast 172.22.22.255 dev eth0 label eth0:1
netsh interface ip add address "vEthernet (WSL)" 172.22.22.21/24

@echo attaching vhd
wsl -- sudo mkdir -p /data
wsl --mount --vhd --bare D:\work\work.vhdx

@echo mounting vhd
wsl -- sudo bash -c "D=\$(lsblk | grep 300G | cut -d' ' -f1); if ! df -h | grep /dev/\$D; then mount /dev/\$D /data; fi"

pause
