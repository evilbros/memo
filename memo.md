# some links

* https://www.desmos.com/calculator
* http://eugen.dedu.free.fr/projects/bresenham/
* https://www.redblobgames.com/grids/line-drawing.html
* http://incompleteideas.net/book/ebook/the-book.html

# armbian: prevent from sleeping
```
systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target
```

# install nodejs

```
wget http://mirrors.ustc.edu.cn/node/v18.15.0/node-v18.15.0-linux-x64.tar.gz
tar -C /usr/local -xf node-v18.15.0-linux-x64.tar.gz
mv /usr/local/node-v18.15.0-linux-x64 /usr/local/node
rm -rf node-v18.15.0-linux-x64.tar.gz
```

# npm registry mirror

```
npm cmd --registry=https://registry.npmmirror.com
```

# install docker

```
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://mirrors.ustc.edu.cn/docker-ce/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install docker-ce docker-compose-plugin
```

# podman notes

* enable podman-restart.service
* start container with --restart=always
* loginctl enable-linger 1000
* config file:

```
[storage]
driver = "overlay"
graphroot = "/home/user/.podman-data/graph"
runroot = "/home/user/.podman-data/run"
```

# git config

```
[user]
    name = evil
    email = evil@x.com
[push]
    default = simple
[color]
    ui = auto
[diff]
    tool = vimdiff
```

# generate self-signed certificate

```bash
FN=test
openssl req -x509 -nodes -days 3650 -newkey rsa:2048 -keyout ${FN}.key -out ${FN}.cert
openssl pkcs12 -inkey ${FN}.key -in ${FN}.cert -export -out ${FN}.pfx
```
