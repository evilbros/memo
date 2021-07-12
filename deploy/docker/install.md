# install docker in centos7

``` bash
curl -o /etc/yum.repos.d/docker-ce.repo https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
yum install -y docker-ce
systemctl enable docker

systemctl start docker

mkdir -p /data/docker-data

cat > /etc/docker/daemon.json << 'EOF' 
{
    "data-root": "/data/docker-data",

    "registry-mirrors": [
    ]
}
EOF

systemctl restart docker
```
