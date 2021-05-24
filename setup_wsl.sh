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
    sed -i 's/^\s*%sudo\s*ALL=(ALL:ALL)/& NOPASSWD:/' /etc/sudoers
fi

# apt
sed -i 's#http://archive.ubuntu.com/ubuntu/#https://mirrors.aliyun.com/ubuntu/#' /etc/apt/sources.list
sed -i 's#http://security.ubuntu.com/ubuntu/#https://mirrors.aliyun.com/ubuntu/#' /etc/apt/sources.list
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

# curl, wget, openssl
apt install -y wget curl

# remove command-not-found
apt autoremove -y command-not-found

# ~/.bashrc
for p in /root /home/game; do
    sed -i 's/^alias l[la=]/#&/' $p/.bashrc
    sed -i 's/^\s*PS1/true #&/'  $p/.bashrc
done

# wsl.conf
cat > /etc/wsl.conf << 'EOF'

[automount]
enabled = true
root = /
options = rw,noatime,uid=1000,gid=1000,metadata,umask=22,fmask=111
mountFsTab = true

EOF

# fstab
grep -E 'c:\s+/c\s+drvfs' /etc/fstab
if [ $? -ne 0 ]; then
cat >> /etc/fstab << 'EOF'
c:  /c  drvfs   rw,noatime,uid=1000,gid=1000,metadata,umask=22,fmask=11 0   0
EOF
fi
