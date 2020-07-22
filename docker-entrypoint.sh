#!/usr/bin/env bash

set -e

openvpn --genkey --secret ta.key

CLIENT_NAME=client

easyrsa gen-req "${CLIENT_NAME}" nopass

easyrsa sign-req client "${CLIENT_NAME}"

cat <<EOF > client/client.ovpn
client
remote ${REMOTE_HOST}
dev tun
proto udp
resolv-retry infinite
nobind
<ca>
$(cat pki/ca.crt)
</ca>
<cert>
$(cat pki/issued/${CLIENT_NAME}.crt)
</cert>
<key>
$(cat pki/private/${CLIENT_NAME}.key)
</key>
key-direction 1
<tls-auth>
$(cat ta.key)
</tls-auth>
cipher AES-256-CBC
verb 3
topology subnet
pull
EOF

iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o eth0 -j MASQUERADE

sed -i 's/DEFAULT_FORWARD_POLICY="DROP"/DEFAULT_FORWARD_POLICY="ACCEPT"/' /etc/default/ufw

exec "$@"
