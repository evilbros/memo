#!/bin/bash

# /etc/bash.bashrc
cat >> /etc/bash.bashrc << 'EOF'

alias ls='ls --color=auto'
alias l='ls -l'
alias ll='ls -la'

alias gits='git status'
alias gitc='git pull --rebase && git status'
alias gitb='git branch -vv'

export TERM=xterm-256color
export PATH=$PATH:/usr/local/go/bin
export GOPROXY=https://mirrors.aliyun.com/goproxy/

_git_prompt() {
    local branch=$(git branch 2>/dev/null | grep \* | cut -d" " -f2)
    if [ $branch ]; then
        printf "[$branch]"
    fi
}

PS1="[\u@\h \W]\[\033[36m\]\$(_git_prompt)\[\033[0m\]\\$ "

umask 022

EOF

# ~/.bashrc
for p in /root; do
    sed -i 's/^alias l[la=]/#&/' $p/.bashrc
    sed -i 's/^\s*PS1/true #&/'  $p/.bashrc
done

# disable selinux
if [ -f /etc/selinux/config ]; then
    sed -i '/^\s*SELINUX=/ c SELINUX=disabled' /etc/selinux/config
    setenforce 0
fi

# limits
grep -E '\s+nofile\s+[0-9]+' /etc/security/limits.conf > /dev/null
if [ $? -ne 0 ]; then
cat >> /etc/security/limits.conf << 'EOF'

*   soft    nofile  99999
*   hard    nofile  99999

EOF
fi

# sudoers
if [ -f /etc/sudoers ]; then
    sed -i 's/^\s*%sudo\s*ALL=(ALL:ALL)/& NOPASSWD:/' /etc/sudoers
fi

# apt
grep 'ubuntu-ports' /etc/apt/sources.list > /dev/null
if [ $? -ne 0 ]; then
    sed -i 's#http://archive.ubuntu.com/ubuntu/#http://mirrors.aliyun.com/ubuntu/#' /etc/apt/sources.list
    sed -i 's#http://security.ubuntu.com/ubuntu/#http://mirrors.aliyun.com/ubuntu/#' /etc/apt/sources.list
else
    sed -i 's#http://ports.ubuntu.com/ubuntu-ports/#http://mirrors.aliyun.com/ubuntu-ports/#' /etc/apt/sources.list
fi
apt update

# vim
apt install -y vim
cat >> /etc/vim/vimrc << 'EOF'

set expandtab tabstop=4 shiftwidth=4 hlsearch
filetype indent on

nmap <C-j> <C-e>
nmap <C-k> <C-y>
nmap <F5> :!./%<CR>

hi DiffAdd    cterm=bold ctermbg=142
hi DiffDelete cterm=bold ctermbg=75
hi DiffChange cterm=bold ctermbg=22
hi DiffText   cterm=bold ctermbg=124

EOF

VIMRUNTIME=$(find /usr/share/vim -maxdepth 1 | grep -E 'vim[0-9]+')
sed -i 's/^\s*set\s*mouse=a/  set mouse=/' $VIMRUNTIME/defaults.vim

# curl, wget, git
apt install -y curl wget git

# remove command-not-found
apt autoremove -y command-not-found

# timezone
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
apt install -y tzdata

# locale
apt install -y locales
sed -i 's/^#\s*\(en_US.UTF-8\s*UTF-8\)/\1/' /etc/locale.gen
locale-gen
update-locale LANG=en_US.UTF-8
sed -i '/^date_fmt\s*"/ s/%r/%T/' /usr/share/i18n/locales/en_US

# build tools
apt install -y build-essential

# golang
GO_VERSION=1.18.3
GO_GZ=go${GO_VERSION}.linux-armv6l.tar.gz

curl -Lo $GO_GZ https://golang.google.cn/dl/$GO_GZ
tar -C /usr/local -xf $GO_GZ
rm -rf $GO_GZ

# nodejs
curl -sL https://deb.nodesource.com/setup_lts.x | bash -
apt install -y nodejs
