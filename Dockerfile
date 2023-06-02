FROM golang:1.17-alpine3.15 AS builder

ENV GO111MODULE on
#ENV GOPROXY https://goproxy.cn

RUN apk update \
    && apk add git \
    && go get github.com/shadowsocks/go-shadowsocks2 \
    && go get github.com/shadowsocks/v2ray-plugin@v1.3.2

FROM quay.io/llrealm/baseutil:main AS dist

#LABEL maintainer="mritd <mritd@linux.com>"

USER 0
ARG gbin="https://github.com/ginuerzh/gost/releases/download/v2.11.1/gost-linux-amd64-2.11.5.gz"
ARG rbin="https://github.com/shadowsocks/shadowsocks-rust/releases/download/v1.15.3/shadowsocks-v1.15.3.x86_64-unknown-linux-musl.tar.xz"
ARG kbin="https://github.com/xtaci/kcptun/releases/download/v20210922/kcptun-linux-amd64-20210922.tar.gz"
ARG vbin="https://github.com/shadowsocks/v2ray-plugin/releases/download/v1.3.2/v2ray-plugin-linux-amd64-v1.3.2.tar.gz"
RUN apk update && apk --no-cache add tzdata \
    && apk --no-cache add --virtual devs gzip tar xz \
    && curl -L -J ${gbin} | gunzip -c > /usr/bin/gost \
    && chmod 755 /usr/bin/gost \
    && cd /tmp && curl -s -L -J ${rbin} | tar -C /usr/bin/ -xJ \
    && curl -s -L -J ${kbin} | tar -C /usr/local/ -xz \
    && ln -s /usr/bin/server_linux_amd64 /usr/bin/kts \
    && ln -s /usr/bin/client_linux_amd64 /usr/bin/ktc \
    && curl -L -J ${vbin} | tar -C /usr/bin/ -xz \
    && ln -s /usr/bin/v2ray-plugin_linux_amd64 /usr/bin/v2ray \
    && apk del --purge devs \
    && apk del --purge curl git openssh-client wget \
    && rm -rf /var/cache/apk/* 

COPY --from=builder /go/bin/go-shadowsocks2 /usr/bin/shadowsocks
#COPY --from=builder /go/bin/v2ray-plugin /usr/bin/v2ray

ENTRYPOINT ["shadowsocks"]
