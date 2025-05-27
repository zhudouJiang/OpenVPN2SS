FROM alpine:latest


RUN sed -i 's#https\?://dl-cdn.alpinelinux.org/alpine#https://mirrors.tuna.tsinghua.edu.cn/alpine#g' /etc/apk/repositories && \
    apk update && \
    apk add --no-cache openvpn openssl curl socat && \
    rm -rf /var/cache/apk/*

RUN set -ex ; \
    apkArch="$(apk --print-arch)" ; \
    case "$apkArch" in \
    x86_64) ssArch='x86_64-unknown-linux-musl' ;; \
    armhf) ssArch='armv7-unknown-linux-musleabihf' ;; \
    aarch64) ssArch='aarch64-unknown-linux-musl' ;; \
    *) echo >&2 "error: unsupported architecture ($apkArch)"; exit 1 ;;\
    esac ; \
    wget -O shadowsocks.tar.xz "https://github.com/shadowsocks/shadowsocks-rust/releases/download/v1.17.0/shadowsocks-v1.17.0.${ssArch}.tar.xz" ; \
    tar -xvJf shadowsocks.tar.xz ; \
    chmod +x ssserver ; \
    mv ssserver /usr/local/bin/ssserver ; \
    rm -rf shadowsocks.tar.xz ssmanager sslocal ssurl ;

RUN mkdir -p /dev/net && \
    mknod /dev/net/tun c 10 200 && \
    chmod 600 /dev/net/tun


COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT ["docker-entrypoint.sh"]
