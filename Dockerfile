FROM debian:buster

RUN apt-get update -y && \
    apt-get install -y \
    ca-certificates \
    easy-rsa \
    openvpn \
    wget \
    gnupg \
    openssl \
    expect \
    net-tools \
    ufw && \
    apt-get autoremove

RUN cp -r /usr/share/easy-rsa/* /usr/local/bin && \
    gzip -d /usr/share/doc/openvpn/examples/sample-config-files/server.conf.gz && \
    cp /usr/share/doc/openvpn/examples/sample-config-files/server.conf /etc/openvpn/

WORKDIR /etc/openvpn

ENV EASYRSA_REQ_CN "default"

ENV EASYRSA_BATCH "yes"

RUN easyrsa init-pki && \
    easyrsa build-ca nopass && \
    easyrsa gen-req server nopass && \
    easyrsa sign-req server server  && \
    easyrsa gen-req client nopass && \
    easyrsa sign-req client client && \
    easyrsa gen-dh

RUN ln -s pki/ca.crt ca.crt && \
    ln -s pki/issued/server.crt server.crt && \
    ln -s pki/private/server.key server.key && \
    ln -s pki/dh.pem dh2048.pem

COPY docker-entrypoint.sh /usr/local/bin/

VOLUME ["/etc/openvpn/client"]

ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["openvpn", "server.conf"]
