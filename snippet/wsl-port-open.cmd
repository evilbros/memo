@echo off

set LXDISTRO=Ubuntu-18.04
set PORT_XXX=12345
set IP=172.22.22.22

netsh interface portproxy add v4tov4 listenport=%PORT_XXX% listenaddress=0.0.0.0 connectport=%PORT_XXX% connectaddress=%IP%
netsh AdvFirewall Firewall add rule name="%LXDISTRO% Port Forward %PORT_XXX%" dir=in action=allow protocol=TCP localport=%PORT_XXX% > NUL

echo port open
