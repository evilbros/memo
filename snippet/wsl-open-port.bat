@echo off

set IP=172.22.22.22
set PORTS=22 80

netsh interface portproxy reset

for %%x in (%PORTS%) do (
    netsh advfirewall firewall delete rule name="wsl-port-%%x" > nul
    netsh advfirewall firewall add rule name="wsl-port-%%x" dir=in action=allow protocol=tcp localport=%%x > nul
    netsh interface portproxy add v4tov4 listenport=%%x listenaddress=0.0.0.0 connectport=%%x connectaddress=%IP% > nul
)

echo port open
