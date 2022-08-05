@echo off

set PORTS=22 8080

netsh interface portproxy reset

for %%x in (%PORTS%) do (
    netsh advfirewall firewall delete rule name="wsl port forward %%x" > nul
)

echo port closed
