FROM ubuntu:dev

# jupyter
RUN apt install -y virtualenv python3-dev libffi-dev && \
    npm install -g tslab && \
    useradd -ms /bin/bash jupyter && \
    sed -i 's/^alias l[la=]/#&/' /home/jupyter/.bashrc && \
    sed -i 's/^\s*PS1/true #&/'  /home/jupyter/.bashrc && \
    echo 'export PATH=/home/jupyter/.local/bin:$PATH' >> /home/jupyter/.bashrc && \
    echo 'export GOPATH=/home/jupyter/.go' >> /home/jupyter/.bashrc

USER jupyter:jupyter
WORKDIR /home/jupyter

RUN virtualenv -p /usr/bin/python3 .py3 && \
    . .py3/bin/activate && \
    pip config set global.index-url https://mirrors.aliyun.com/pypi/simple && \
    pip install jupyterlab && \
    tslab install
COPY --chown=jupyter:jupyter gophernotes/* .local/share/jupyter/kernels/gophernotes/

# start
ENV PASSWORD='argon2:$argon2id$v=19$m=10240,t=10,p=8$nZKa+i4jnicCVmK3i3zTSQ$qLr6SZK0FQ50Ca39FqnGLg'
ENV BASE_URL=/jupyter/

EXPOSE 8888

CMD .py3/bin/jupyter \
lab \
--ServerApp.allow_remote_access=True \
--ServerApp.ip='*' \
--Serverapp.port=8888 \
--ServerApp.terminado_settings='{"shell_command": ["/bin/bash"]}' \
--ServerApp.password=$PASSWORD \
--ServerApp.base_url=$BASE_URL

