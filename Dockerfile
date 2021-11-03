FROM golang:1.16-alpine3.14 AS builder

ENV GO111MODULE on
#ENV GOPROXY https://goproxy.cn

RUN apk upgrade \
    && apk add git \
    && go get github.com/shadowsocks/go-shadowsocks2 \
    && go get github.com/shadowsocks/v2ray-plugin

FROM alpine:3.13 AS dist

#LABEL maintainer="mritd <mritd@linux.com>"

ARG gbin="https://github.com/ginuerzh/gost/releases/download/v2.11.1/gost-linux-amd64-2.11.1.gz"
ARG rbin="https://github.com/shadowsocks/shadowsocks-rust/releases/download/v1.11.2/shadowsocks-v1.11.2.x86_64-unknown-linux-musl.tar.xz"
ARG kbin="https://github.com/xtaci/kcptun/releases/download/v20210922/kcptun-linux-amd64-20210922.tar.gz"
RUN apk upgrade \
    && apk --no-cache add curl tzdata \
    && apk --no-cache add --virtual devs gzip tar xz \
    && curl -L -J ${gbin} | gunzip -c > /usr/bin/gost \
    && chmod 755 /usr/bin/gost \
    && cd /tmp && curl -s -L -J ${rbin} -o /tmp/ss.tar.xz \
    && tar -xvf ss.tar.xz -C /usr/bin \
    && curl -s -L -J ${kbin} -o /tmp/kbin.tar.gz \
    && tar -xvf kbin.tar.gz -C /usr/bin \
    && ln -s /usr/bin/server_linux_amd64 /usr/bin/kts \
    && ln -s /usr/bin/client_linux_amd64 /usr/bin/ktc \
    && apk del --purge devs \
    && rm -rf /var/cache/apk/* \
    && rm /tmp/ss.tar.xz /tmp/kbin.tar.gz

COPY --from=builder /go/bin/go-shadowsocks2 /usr/bin/shadowsocks
COPY --from=builder /go/bin/v2ray-plugin /usr/bin/v2ray

ENTRYPOINT ["shadowsocks"]
