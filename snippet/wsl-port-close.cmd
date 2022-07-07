@echo off

set LXDISTRO=Ubuntu-18.04
set PORT_XXX=12345

netsh interface portproxy reset
netsh AdvFirewall Firewall delete rule name="%LXDISTRO% Port Forward %PORT_XXX%" > NUL

echo port closed
