FROM ubuntu

RUN sed -i 's#http://\w*.ubuntu.com/#http://mirrors.ustc.edu.cn/#' /etc/apt/sources.list && \
    apt update && \
    apt install -y openssh-server git && \
    mkdir /run/sshd && \
    useradd -ms /bin/bash git && \
    su - git -c 'mkdir repo; mkdir .ssh; chmod 700 .ssh'

EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]

