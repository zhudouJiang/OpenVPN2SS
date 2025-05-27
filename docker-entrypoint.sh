#!/bin/sh

# 启动 OpenVPN
nohup openvpn --config /etc/openvpn-config/openvpn.ovpn --auth-user-pass /etc/openvpn-config/pass.txt >> /var/log/custom/ovpn.log &
sleep 8

# 启动 Shadowsocks 到后台
ssserver -c /etc/shadowsocks.json &

# 宿主机 IP，用于转发目标
HOST_IP=0.250.250.254

# 要转发的端口列表
PORTS="8081 8082 8083 8084 8085 8086 8087 8088 8089"

# 启动 socat 转发（每个端口启动一个后台任务）
for PORT in $PORTS; do
  echo "[INFO] Forwarding :$PORT -> $HOST_IP:$PORT"
  socat TCP-LISTEN:$PORT,fork TCP:$HOST_IP:$PORT &
done

# 打印 tun0 IP（此处 tun0 可能未创建或取法不同，请确认）
IP=$(ip addr show tun0 | grep 'inet ' | awk '{print $2}' | cut -d'/' -f1)
echo "[INFO] tun0 的 IP 地址是: $IP"

echo SPRING_CLOUD_NACOS_DISCOVERY_IP=$IP >/etc/openvpn-config/.env

# 保持容器前台不退出
wait
