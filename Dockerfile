FROM ghcr.io/weaveworks/tf-runner:v0.13.0-rc.1 as tf-runner

FROM alpine:3.16

RUN apk add --no-cache ca-certificates tini git openssh-client gnupg && \
    apk add --no-cache libretls && \
    apk add --no-cache busybox && \
    apk add --no-cache aws-cli


COPY --from=tf-runner /usr/local/bin/tf-runner /usr/local/bin/
COPY --from=tf-runner /usr/local/bin/terraform /usr/local/bin/


# Create minimal nsswitch.conf file to prioritize the usage of /etc/hosts over DNS queries.
# https://github.com/gliderlabs/docker-alpine/issues/367#issuecomment-354316460
RUN [ ! -e /etc/nsswitch.conf ] && echo 'hosts: files dns' > /etc/nsswitch.conf

RUN addgroup --gid 65532 -S runner && adduser --uid 65532 -S runner -G runner && chmod +x /usr/bin/aws && chmod +x /usr/local/bin/terraform


USER 65532:65532

ENV GNUPGHOME=/tmp

ENTRYPOINT [ "/sbin/tini", "--", "tf-runner" ]

