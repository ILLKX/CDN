#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
#=================================================================#
#   System Required: CentOS 7 X86_64                              #
#   Description: Aria2+AriaNG+GoHttpServer Soft Install           #
#   Author: LALA <QQ1062951199>                                   #
#   Website: https://www.lala.im                                  #
#=================================================================#

clear
echo
echo "#############################################################"
echo "# Aria2 + AriaNG + GoHttpServer Soft Install                #"
echo "# Author: LALA <QQ1062951199>                               #"
echo "# Website: https://www.lala.im                              #"
echo "# System Required: CentOS 7 X86_64                          #"
echo "#############################################################"
echo

# Color
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
font="\033[0m"

# HostIP input
read -p "请输入你的主机公网IP地址或域名:" HostIP

# Setting Aria2 RPC password
read -p "设置Aria2RPC连接密码:" rpcpw

# Setting GoHttpServer Username
read -p "设置GoHttpServerWeb账号:" ghsua

# Setting GohttpServer Password
read -p "设置GoHttpServerWeb密码:" ghspw

# Setting GohttpServer WebTitle
read -p "设置GoHttpServer监听端口:" ghsport

# Setting GohttpServer WebTitle
read -p "设置GoHttpServer网站标题:" ghstitle

# CPUcore input
read -p "选择使用多少个CPU线程进行编译（多个线程将有效提升编译效率）:" CPUcore

# Create Swap
read -p "如果机器内存小于2GB需临时创建Swap,是否创建Swap?（yes/no）:" Choose
if [ $Choose = "yes" ];then
	dd if=/dev/zero of=/var/swap bs=1024 count=2097152
	mkswap /var/swap
	chmod 0600 /var/swap
	swapon /var/swap
fi
if [ $Choose = "no" ]
then
    echo -e "${yellow} 你选择不创建swap,脚本将继续进行下一步操作 ${font}"
fi

# Disable SELinux Function
disable_selinux(){
    if [ -s /etc/selinux/config ] && grep 'SELINUX=enforcing' /etc/selinux/config; then
        sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
        setenforce 0
    fi
}
# Stop SElinux
disable_selinux

# Disable Firewalld
systemctl stop firewalld.service
systemctl disable firewalld.service
systemctl stop iptables.service
systemctl disable iptables.service

# Update System
yum -y update
if [ $? -eq 0 ];then
    echo -e "${green} 系统更新完成 ${font}"
else 
    echo -e "${red} 系统更新失败 ${font}"
    exit 1
fi

# Install Required
yum -y install epel-release
if [ $? -eq 0 ];then
    echo -e "${green} EPEL源安装成功 ${font}"
else 
    echo -e "${red} EPEL源安装失败 ${font}"
    exit 1
fi
yum -y groupinstall "Development Tools"
if [ $? -eq 0 ];then
    echo -e "${green} 开发工具包安装成功 ${font}"
else 
    echo -e "${red} 开发工具包安装失败 ${font}"
    exit 1
fi
yum -y install openssl-devel
if [ $? -eq 0 ];then
    echo -e "${green} Openssl-Devel安装成功 ${font}"
else 
    echo -e "${red} Openssl-Devel安装失败 ${font}"
    exit 1
fi
yum -y install unzip
if [ $? -eq 0 ];then
    echo -e "${green} Unzip安装成功 ${font}"
else 
    echo -e "${red} Unzip安装失败 ${font}"
    exit 1
fi

# Download Aria2 source and Install
cd
wget https://github.com/aria2/aria2/releases/download/release-1.35.0/aria2-1.35.0.tar.gz
if [ $? -eq 0 ];then
    echo -e "${green} Aria2源码下载成功 ${font}"
else 
    echo -e "${red} Aria2源码下载失败 ${font}"
    exit 1
fi
tar -xzvf aria2-1.35.0.tar.gz
cd aria2-1.35.0
./configure --prefix=/usr
make -j${CPUcore}
make install
if [ $? -eq 0 ];then
    echo -e "${green} Aria2安装成功 ${font}"
else 
    echo -e "${red} Aria2安装失败 ${font}"
    exit 1
fi

# Create Aria2 Setting folder and files
mkdir -p /etc/aria2/
touch /etc/aria2/aria2.session
touch /etc/aria2/aria2.conf

# Import Aria2 Setting
cat > /etc/aria2/aria2.conf <<EOF
## '#'开头为注释内容, 选项都有相应的注释说明, 根据需要修改 ##
## 被注释的选项填写的是默认值, 建议在需要修改时再取消注释  ##

## 文件保存相关 ##

# 文件的保存路径(可使用绝对路径或相对路径), 默认: 当前启动位置
dir=/sometimesnaive
# 启用磁盘缓存, 0为禁用缓存, 需1.16以上版本, 默认:16M
disk-cache=16M
# 文件预分配方式, 能有效降低磁盘碎片, 默认:prealloc
# 预分配所需时间: none < falloc ? trunc < prealloc
# falloc和trunc则需要文件系统和内核支持
# NTFS建议使用falloc, EXT3/4建议trunc, MAC 下需要注释此项
#file-allocation=none
# 断点续传
continue=true

## 下载连接相关 ##

# 最大同时下载任务数, 运行时可修改, 默认:5
max-concurrent-downloads=50
# 同一服务器连接数, 添加时可指定, 默认:1
max-connection-per-server=5
# 最小文件分片大小, 添加时可指定, 取值范围1M -1024M, 默认:20M
# 假定size=10M, 文件为20MiB 则使用两个来源下载; 文件为15MiB 则使用一个来源下载
min-split-size=10M
# 单个任务最大线程数, 添加时可指定, 默认:5
#split=5
# 整体下载速度限制, 运行时可修改, 默认:0
#max-overall-download-limit=0
# 单个任务下载速度限制, 默认:0
#max-download-limit=0
# 整体上传速度限制, 运行时可修改, 默认:0
#max-overall-upload-limit=0
# 单个任务上传速度限制, 默认:0
#max-upload-limit=0
# 禁用IPv6, 默认:false
#disable-ipv6=true
# 连接超时时间, 默认:60
#timeout=60
# 最大重试次数, 设置为0表示不限制重试次数, 默认:5
#max-tries=5
# 设置重试等待的秒数, 默认:0
#retry-wait=0

## 进度保存相关 ##

# 从会话文件中读取下载任务
input-file=/etc/aria2/aria2.session
# 在Aria2退出时保存错误/未完成的下载任务到会话文件
save-session=/etc/aria2/aria2.session
# 定时保存会话, 0为退出时才保存, 需1.16.1以上版本, 默认:0
save-session-interval=0
# 即使下载完成或删除也全部保存
force-save=true

## RPC相关设置 ##

# 启用RPC, 默认:false
enable-rpc=true
# 允许所有来源, 默认:false
rpc-allow-origin-all=true
# 允许非外部访问, 默认:false
rpc-listen-all=true
# 事件轮询方式, 取值:[epoll, kqueue, port, poll, select], 不同系统默认值不同
#event-poll=select
# RPC监听端口, 端口被占用时可以修改, 默认:6800
rpc-listen-port=6800
# 设置的RPC授权令牌, v1.18.4新增功能, 取代 --rpc-user 和 --rpc-passwd 选项
rpc-secret=${rpcpw}
# 设置的RPC访问用户名, 此选项新版已废弃, 建议改用 --rpc-secret 选项
#rpc-user=<USER>
# 设置的RPC访问密码, 此选项新版已废弃, 建议改用 --rpc-secret 选项
#rpc-passwd=<PASSWD>
# 是否启用 RPC 服务的 SSL/TLS 加密,
# 启用加密后 RPC 服务需要使用 https 或者 wss 协议连接
#rpc-secure=true
# 在 RPC 服务中启用 SSL/TLS 加密时的证书文件,
# 使用 PEM 格式时，您必须通过 --rpc-private-key 指定私钥
#rpc-certificate=/path/to/certificate.pem
# 在 RPC 服务中启用 SSL/TLS 加密时的私钥文件
#rpc-private-key=/path/to/certificate.key

## BT/PT下载相关 ##

# 当下载的是一个种子(以.torrent结尾)时, 自动开始BT任务, 默认:true
#follow-torrent=true
# BT监听端口, 当端口被屏蔽时使用, 默认:6881-6999
listen-port=51413
# 单个种子最大连接数, 默认:55
bt-max-peers=500
# 打开DHT功能, PT需要禁用, 默认:true
enable-dht=true
# 打开IPv6 DHT功能, PT需要禁用
enable-dht6=true
# DHT网络监听端口, 默认:6881-6999
dht-listen-port=6881-6999
# 本地节点查找, PT需要禁用, 默认:false
bt-enable-lpd=true
# 种子交换, PT需要禁用, 默认:true
enable-peer-exchange=true
# 每个种子限速, 对少种的PT很有用, 默认:50K
#bt-request-peer-speed-limit=50K
# 客户端伪装, PT需要
#peer-id-prefix=-TR2770-
#user-agent=Transmission/2.77
# 当种子的分享率达到这个数时, 自动停止做种, 0为一直做种, 默认:1.0
seed-ratio=0
# 强制保存会话, 即使任务已经完成, 默认:false
# 较新的版本开启后会在任务完成后依然保留.aria2文件
#force-save=false
# BT校验相关, 默认:true
#bt-hash-check-seed=true
# 继续之前的BT任务时, 无需再次校验, 默认:false
bt-seed-unverified=true
# 保存磁力链接元数据为种子文件(.torrent文件), 默认:false
bt-save-metadata=true
EOF

# Download AriaNG
mkdir -p /AriaNG && cd /AriaNG
wget -O AriaNg-0.5.0.zip https://cdn.jsdelivr.net/gh/ILLKX/CDN@master/AriaNG.zip
if [ $? -eq 0 ];then
    echo -e "${green} AriaNG下载成功 ${font}"
else 
    echo -e "${red} AriaNG下载失败 ${font}"
    exit 1
fi
unzip AriaNg-0.5.0.zip
if [ $? -eq 0 ];then
    echo -e "${green} AriaNG解压成功 ${font}"
else 
    echo -e "${red} AriaNG解压失败 ${font}"
    exit 1
fi

# Download GohttpServer File
cd
wget --no-check-certificate https://github.com/codeskyblue/gohttpserver/releases/download/1.0.5/gohttpserver_1.0.5_linux_amd64.zip
if [ $? -eq 0 ];then
    echo -e "${green} GoHttpServer文件下载成功 ${font}"
else 
    echo -e "${red} GoHttpServer文件下载失败 ${font}"
    exit 1
fi
unzip gohttpserver_1.0.5_linux_amd64.zip -d gohttpserver
cd gohttpserver
mv gohttpserver /usr/bin

# Remove Naive
rm -rf /root/gohttpserver
rm -rf /root/gohttpserver_1.0.5_linux_amd64.zip

# Setting Download Folder
mkdir -p /sometimesnaive


# Install Caady HTTP Server
cd
ulimit -n 8192
mkdir -p caddy && cd caddy
wget --no-check-certificate https://github.com/mholt/caddy/releases/download/v0.11.0/caddy_v0.11.0_linux_amd64.tar.gz
if [ $? -eq 0 ];then
    echo -e "${green} Caddy下载成功 ${font}"
else 
    echo -e "${red} Caddy下载失败 ${font}"
    exit 1
fi
tar -xzvf caddy_v0.11.0_linux_amd64.tar.gz
mv caddy /usr/bin

# Remove Naive
rm -rf /root/caddy
rm -rf /root/caddy_v0.11.0_linux_amd64.tar.gz

# Create Caddy Conf
mkdir -p /etc/caddy
touch /etc/caddy/Caddyfile
cat > /etc/caddy/Caddyfile <<EOF
${HostIP}:2018
gzip
root /AriaNG
EOF

# Create Caddy Server File
touch /usr/lib/systemd/system/caddy.service
cat > /usr/lib/systemd/system/caddy.service <<EOF
[Unit]
Description=Caddy HTTP/2 web server
Documentation=https://caddyserver.com/docs
After=network-online.target
Wants=network-online.target systemd-networkd-wait-online.service

[Service]
Restart=on-abnormal
User=root
Group=root
ExecStart=/usr/bin/caddy -log stdout -agree=true -conf=/etc/caddy/Caddyfile -root=/var/tmp
ExecReload=/bin/kill -USR1 \$MAINPID
KillMode=mixed
KillSignal=SIGQUIT
TimeoutStopSec=5s
LimitNPROC=512

[Install]
WantedBy=multi-user.target
EOF

# Create GohttpServer Server File
touch /usr/lib/systemd/system/gohttpserver.service
cat > /usr/lib/systemd/system/gohttpserver.service <<EOF
[Unit]
Description=gohttpserver
[Service]
User=root
Group=root
ExecStart=/usr/bin/gohttpserver -r /sometimesnaive --upload --delete --title=${ghstitle} --port=${ghsport} --auth-type http --auth-http ${ghsua}:${ghspw} --theme=black
Restart=on-abort
[Install]
WantedBy=multi-user.target
EOF

# Create Aria2 Service File
touch /etc/systemd/system/aria2.service
cat > /etc/systemd/system/aria2.service <<EOF
[Unit]
Description=aria2
[Service]
User=root
Group=root
ExecStart=/usr/bin/aria2c --conf-path=/etc/aria2/aria2.conf
Restart=on-abort
[Install]
WantedBy=multi-user.target
EOF

# Beautiful Girl
systemctl start caddy
systemctl start gohttpserver
systemctl start aria2
systemctl enable caddy
systemctl enable gohttpserver
systemctl enable aria2

echo
echo "#############################################################"
echo "# Aria2 + AriaNG + GoHttpServer Installation Complete       #"
echo "# AriaNG WebSite: http://${HostIP}:2018                     #"
echo "# Aria2 RPC Password: ${rpcpw}                              #"
echo "# GohttpServer WebSite: http://${HostIP}:${ghsport}         #"
echo "# GohttpServer UserName: ${ghsua}                           #"
echo "# GohttpServer PassWord: ${ghspw}                           #"
echo "#############################################################"
echo
