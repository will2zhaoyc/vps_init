#!/bin/bash

# 更新软件源
echo "正在更新软件源..."
apt update > /dev/null 2>&1
echo "软件源已更新"

# 启用 BBR TCP 拥塞控制算法
echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
sysctl -p > /dev/null 2>&1
echo "BBR TCP 拥塞控制算法已启用"

# 安装 x-ui：
echo "正在安装 x-ui..."
bash <(curl -Ls https://raw.githubusercontent.com/vaxilu/x-ui/master/install.sh) > /dev/null 2>&1
echo "x-ui 已安装"

# 安装 nginx
echo "正在安装 nginx..."
apt install nginx -y > /dev/null 2>&1
echo "nginx 已安装"

# 安装 acme：
echo "正在安装 acme.sh..."
curl https://get.acme.sh | sh > /dev/null 2>&1
echo "acme.sh 已安装"

# 添加软链接
ln -s  /root/.acme.sh/acme.sh /usr/local/bin/acme.sh
echo "软链接已添加"

# 切换 CA 机构
echo "正在切换 CA 机构..."
acme.sh --set-default-ca --server letsencrypt > /dev/null 2>&1
echo "CA 机构已切换"

# 输入用户域名
read -p "请输入您的域名: " domain

# 申请证书
echo "正在申请证书..."
acme.sh --issue -d $domain -k ec-256 --webroot /var/www/html > /dev/null 2>&1
echo "证书已申请"

# 安装证书
echo "正在安装证书..."
acme.sh --install-cert -d $domain --ecc --key-file /etc/x-ui/server.key --fullchain-file /etc/x-ui/server.crt --reloadcmd "systemctl force-reload nginx" > /dev/null 2>&1
echo "证书已安装"

echo "所有操作已完成"
