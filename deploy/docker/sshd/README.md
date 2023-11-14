## debian sshd

* user 'game' is created without password
* executable ```/init.sh``` will be executed when the container is started
* build command:
```
podman build -t sshd .
```
* container creation
```
podman run -d --name mysshd -p 10022:22 -v /path/to/ssh:/home/game/.ssh sshd
```

