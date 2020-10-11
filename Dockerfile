FROM golang:1.14.4-alpine3.12 AS builder

ENV GO111MODULE on
#ENV GOPROXY https://goproxy.cn

RUN apk upgrade \
    && apk add git \
    && go get github.com/Yawning/obfs4 \
    && go get github.com/shadowsocks/go-shadowsocks2 \
    && go get github.com/shadowsocks/v2ray-plugin \
    && go get github.com/ginuerzh/gost

FROM alpine:3.12 AS dist

#LABEL maintainer="mritd <mritd@linux.com>"

RUN apk upgrade \
    && apk add tzdata \
    && rm -rf /var/cache/apk/*

COPY --from=builder /go/bin/go-shadowsocks2 /usr/bin/shadowsocks
COPY --from=builder /go/bin/v2ray-plugin /usr/bin/v2ray
COPY --from=builder /go/bin/gost /usr/bin/gost


ENTRYPOINT ["shadowsocks"]
