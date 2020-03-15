#!/bin/bash
# FILE="/etc/Caddy"
domain="$1"
psname="$2"
uuid="$3"

# v2ray
cat > /etc/v2ray/config.json <<'EOF'
{
  "log": {
    "loglevel": "warning"
  },
  "inbound": {
    "port": 1080,
    "listen": "0.0.0.0",
    "protocol": "socks",
    "settings": {
      "auth": "noauth",
      "udp": false
    }
  },
  "inboundDetour": [
    {
        "port": 8123,
        "listen": "0.0.0.0",
        "protocol": "http",
        "settings": {}
    }
  ],
  "outbound": {
    "protocol": "vmess",
    "settings": {
      "vnext": [{
        "address": "domain", // 服务器地址，请修改为你自己的服务器 ip 或域名
        "port": 443,  // 服务器端口
        "users": [{
            "id": "uuid", //你的UUID， 此ID需与服务端保持一致
            "level": 1,
            "alterId": 4,  //此ID也需与客户端保持一致
            "security": "aes-128-gcm"
        }]
      }]
    },
    "streamSettings":{
        "network": "ws",
        "security": "tls",
        "tlsSettings": {
            "serverName": "domain" //此域名是你服务器的域名
        },
        "wsSettings": {
            "path": "/one" //与服务器配置及nginx配置相关
        }
    },
    "tag": "forgin"
  },
  "outboundDetour": [
    {
        "protocol": "freedom",
        "settings": {},
        "tag": "direct"
    }
  ],
  "routing": { //此路由配置是自动分流， 国内IP和网站直连
    "strategy": "rules",
    "settings": {
        "domainStrategy": "IPIfNonMatch",
        "rules": [
            {
                "type": "chinaip",
                "outboundTag": "direct"
            },
            {
                "type": "chinasites",
                "outboundTag": "direct"
            },
            {
                "type": "field",
                "ip": [
                    "0.0.0.0/8",
                    "10.0.0.0/8",
                    "100.64.0.0/10",
                    "127.0.0.0/8",
                    "169.254.0.0/16",
                    "172.16.0.0/12",
                    "192.0.0.0/24",
                    "192.0.2.0/24",
                    "192.168.0.0/16",
                    "198.18.0.0/15",
                    "198.51.100.0/24",
                    "203.0.113.0/24",
                    "::1/128",
                    "fc00::/7",
                    "fe80::/10"
                ],
                "outboundTag": "direct"
            }
        ]
    }
  },
  "policy": {
    "levels": {
      "0": {"uplinkOnly": 0}
    }
  }
}

EOF

sed -i "s/uuid/${uuid}/" /etc/v2ray/config.json
sed -i "s/\bdomain\b/${domain}/" /etc/v2ray/config.json

/usr/bin/v2ray -config /etc/v2ray/config.json
