# some links

* https://www.desmos.com/calculator
* http://eugen.dedu.free.fr/projects/bresenham/
* https://www.redblobgames.com/grids/line-drawing.html
* http://incompleteideas.net/book/ebook/the-book.html

# install nodejs

* centos

```
curl -sL https://rpm.nodesource.com/setup_lts.x | bash -
yum install -y nodejs
```

* ubuntu

```
curl -sL https://deb.nodesource.com/setup_lts.x | bash -
apt install -y nodejs
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
NAME=test openssl req -x509 -nodes -days 3650 -newkey rsa:2048 -keyout ${NAME}.key -out ${NAME}.cert
NAME=test openssl pkcs12 -inkey ${NAME}.key -in ${NAME}.cert -export -out ${NAME}.pfx
```
