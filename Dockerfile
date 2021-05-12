FROM golang:1.16.2-alpine3.13 AS builder

ENV GO111MODULE on
#ENV GOPROXY https://goproxy.cn

RUN apk upgrade \
    && apk add git \
    && go get github.com/shadowsocks/go-shadowsocks2 \
    && go get github.com/shadowsocks/v2ray-plugin

FROM alpine:3.13 AS dist

#LABEL maintainer="mritd <mritd@linux.com>"

ARG gbin="https://github.com/ginuerzh/gost/releases/download/v2.11.1/gost-linux-amd64-2.11.1.gz"
ARG rbin="https://github.com/shadowsocks/shadowsocks-rust/releases/download/v1.10.9/shadowsocks-v1.10.9.x86_64-unknown-linux-musl.tar.xz"
RUN apk upgrade \
    && apk add curl gzip tar tzdata \
    && curl -L -J ${gbin} | gunzip -c > /usr/bin/gost \
    && chmod 755 /usr/bin/gost \
    && cd /tmp && curl -L -J ${rbin} -o /tmp/ss.tar.xz | tar --no-same-owner  -xf ss.tar.xz -C /usr/bin/ \ 
    && rm /tmp/ss.tar.xz \
    && rm -rf /var/cache/apk/*

COPY --from=builder /go/bin/go-shadowsocks2 /usr/bin/shadowsocks
COPY --from=builder /go/bin/v2ray-plugin /usr/bin/v2ray

ENTRYPOINT ["shadowsocks"]
