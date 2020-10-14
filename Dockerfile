FROM golang:1.14.4-alpine3.12 AS builder

ENV GO111MODULE on
#ENV GOPROXY https://goproxy.cn

RUN apk upgrade \
    && apk add git \
    && go get github.com/shadowsocks/go-shadowsocks2 \
    && go get github.com/shadowsocks/v2ray-plugin

FROM alpine:3.12 AS dist

#LABEL maintainer="mritd <mritd@linux.com>"

ARG gbin="https://github.com/ginuerzh/gost/releases/download/v2.11.1/gost-linux-amd64-2.11.1.gz"
RUN apk upgrade \
    && apk add curl gzip tzdata \
    && curl -L -J ${gbin} | gunzip -c > /usr/bin/gost \
    && chmod 755 /usr/bin/gost \
    && rm -rf /var/cache/apk/*

COPY --from=builder /go/bin/go-shadowsocks2 /usr/bin/shadowsocks
COPY --from=builder /go/bin/v2ray-plugin /usr/bin/v2ray

ENTRYPOINT ["shadowsocks"]