# some links

* https://www.desmos.com/calculator
* http://eugen.dedu.free.fr/projects/bresenham/
* https://www.redblobgames.com/grids/line-drawing.html
* http://incompleteideas.net/book/ebook/the-book.html

# install nodejs

```
wget http://mirrors.ustc.edu.cn/node/v18.15.0/node-v18.15.0-linux-x64.tar.gz
tar -C /usr/local -xf node-v18.15.0-linux-x64.tar.gz
mv /usr/local/node-v18.15.0-linux-x64 /usr/local/node
rm -rf node-v18.15.0-linux-x64.tar.gz
```

# install docker

```
curl -fsSL https://mirrors.ustc.edu.cn/docker-ce/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/trusted.gpg.d/docker.gpg
echo "deb https://mirrors.ustc.edu.cn/docker-ce/linux/ubuntu focal stable" > /etc/apt/sources.list.d/docker-ce.list
apt update
apt install docker-ce docker-compose-plugin
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
