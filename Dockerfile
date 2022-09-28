FROM alpine:3.16 as builder

RUN apk add --no-cache \
        python3 \
        py3-pip \
    && pip3 install --upgrade pip \
    && pip3 install --no-cache-dir \
        awscli \
    && rm -rf /var/cache/apk/*

RUN apk add --update util-linux

FROM ghcr.io/weaveworks/tf-runner:v0.13.0-rc.1

COPY --from=builder "/usr/bin/aws" "/usr/bin/aws"


ENTRYPOINT [ "/sbin/tini", "--", "tf-runner" ]