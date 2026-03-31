#!/bin/bash

ROOT_DIR=/data/isolated
DISTRO=${2:-ubuntu}
SANDBOX=$ROOT_DIR/$DISTRO
PIDFILE="/tmp/bwrap-$DISTRO.pid"
ROOTFS_TAR=$ROOT_DIR/rootfs-$DISTRO.tar

init() {
    if [ -d "$SANDBOX/bin" ] || [ -d "$SANDBOX/sbin" ]; then
        echo "已初始化: $SANDBOX (跳过)"
        return 0
    fi

    if [ ! -f "$ROOTFS_TAR" ]; then
        echo "错误: 当前目录没有 $ROOTFS_TAR"
        exit 1
    fi

    echo "解压 $ROOTFS_TAR 到 $SANDBOX ..."
    mkdir -p "$SANDBOX"
    tar -xf "$ROOTFS_TAR" -C "$SANDBOX"

    echo "配置 apt ..."
    mkdir -p "$SANDBOX/etc/apt/apt.conf.d"
    echo -e 'APT::Sandbox::User "root";\nAPT::Sandbox::Group "root";' > "$SANDBOX/etc/apt/apt.conf.d/99root"

    echo "修复权限 ..."
    chown -R 0:0 "$SANDBOX/var/cache/apt" 2>/dev/null || true
    chown -R 0:0 "$SANDBOX/var/log/apt" 2>/dev/null || true

    echo "沙盒就绪: $SANDBOX"
}

nsenter_container() {
    local PID=$1
    echo "进入容器 (PID: $PID)..."
    # 显式指定用户命名空间路径，避免 -U 可能的问题
    sudo nsenter -t "$PID" --user=/proc/"$PID"/ns/user -m -p -u -i /bin/bash
}

start() {
    # 自动初始化（若沙盒不存在）
    if [ ! -d "$SANDBOX/bin" ] && [ ! -d "$SANDBOX/sbin" ]; then
        init
    fi

    # 检查容器是否已经在运行
    if [ -f "$PIDFILE" ]; then
        PID=$(cat "$PIDFILE")
        if kill -0 "$PID" 2>/dev/null; then
            echo "容器已在运行，进入..."
            nsenter_container "$PID"
            return 0
        else
            echo "容器未运行，清除旧PID文件"
            rm -f "$PIDFILE"
        fi
    fi

    echo "启动新容器..."
    # 以后台方式启动 bwrap，显式指定命名空间（排除用户命名空间）
    bwrap \
        --bind "$SANDBOX" / \
        --proc /proc \
        --dev /dev \
        --dev-bind /dev/pts /dev/pts \
        --bind /etc/resolv.conf /etc/resolv.conf \
        --tmpfs /tmp \
        --unshare-all \
        --share-net \
        --uid 0 \
        --gid 0 \
        --clearenv \
        /bin/sleep infinity &
    BPID=$!
    # 短暂等待，确保进程启动
    sleep 1
    if ! kill -0 "$BPID" 2>/dev/null; then
        echo "启动失败"
        exit 1
    fi

    # 获取 bwrap 的子进程 PID（即 sleep infinity）
    CHILD_PID=$(pgrep -P "$BPID" | head -1)
    if [ -z "$CHILD_PID" ]; then
        echo "未找到容器内进程"
        exit 1
    fi
    echo "$CHILD_PID" > "$PIDFILE"
    echo "容器已启动 (容器内进程 PID: $CHILD_PID)"
    nsenter_container "$CHILD_PID"
}

stop() {
    if [ -f "$PIDFILE" ]; then
        PID=$(cat "$PIDFILE")
        if kill -0 "$PID" 2>/dev/null; then
            echo "停止容器 (PID: $PID)..."
            kill -9 "$PID"
        fi
        rm -f "$PIDFILE"
    else
        echo "未找到运行中的容器"
    fi
    echo "已停止"
}

case "$1" in
    init)   init ;;
    start)  start ;;
    stop)   stop ;;
    *)      echo "用法: $0 {init|start|stop} [distro=ubuntu]" ;;
esac
