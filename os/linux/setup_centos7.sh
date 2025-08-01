#!/bin/bash

# /etc/bashrc
cat >> /etc/bashrc << 'EOF'

alias ls='ls --color=auto'
alias l='ls -l'
alias ll='ls -la'

alias grep='grep --color=auto'

alias gits='git status'
alias gitc='git pull --rebase && git status'
alias gitb='git branch -vv'

export TERM=xterm-256color
export PATH=$PATH:/usr/local/go/bin:/usr/local/node/bin
export GOPROXY=https://goproxy.cn
export LANG=en_US.UTF-8

# PS1
[ -r /etc/debian_chroot ] && chroot_dir=$(</etc/debian_chroot)

_git_prompt() {
    local branch=$(git branch 2>/dev/null | grep \* | cut -d" " -f2-)
    [ "$branch" ] && printf "[$branch]"
}

PS1="${chroot_dir:+($chroot_dir)}"
if [ $(id -u) -eq 0 ]; then
    PS1="$PS1[\u@\h \W]"
else
    PS1="$PS1\[\033[1;32m\]\u@\h\[\033[0m\] \[\033[1;34m\]\W\[\033[0m\]"
fi
PS1="$PS1\[\033[36m\]\$(_git_prompt)\[\033[0m\]\\$ "

# HOME
[ ! "$HOME" ] && export HOME=$(realpath ~)

umask 022

EOF

# disable selinux
if [ -f /etc/selinux/config ]; then
    sed -i '/^\s*SELINUX=/ c SELINUX=disabled' /etc/selinux/config
    setenforce 0
fi

# limits
grep -E '\s+nofile\s+[0-9]+' /etc/security/limits.conf
if [ $? -ne 0 ]; then
cat >> /etc/security/limits.conf << 'EOF'

*   soft    nofile  99999
*   hard    nofile  99999

EOF
fi

# sudoers
if [ -f /etc/sudoers ]; then
    sed -i 's/^%wheel\s*ALL=(ALL)\s*ALL/# &/' /etc/sudoers
    sed -i 's/^#\s*\(%wheel\s*ALL=(ALL)\s*NOPASSWD:\s*ALL\)/\1/' /etc/sudoers
fi

# yum repo
curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
curl -o /etc/yum.repos.d/epel.repo        http://mirrors.aliyun.com/repo/epel-7.repo
sed -i '/aliyuncs/d' /etc/yum.repos.d/CentOS-Base.repo
sed -i '/aliyuncs/d' /etc/yum.repos.d/epel.repo
yum makecache

# vim
yum install -y vim
cat >> /etc/vimrc << 'EOF'

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

# curl, wget, openssl
yum install -y wget curl
yum update -y openssl
