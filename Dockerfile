#FROM busybox:1-glibc
FROM progrium/busybox

MAINTAINER Steve Shipway <steve@steveshipway.org>

VOLUME /conf /certs /data

WORKDIR /conf

RUN opkg-install wget openssl-util ca-certificates

COPY startup.sh /usr/local/bin/startup.sh

ENV CFG_CERT= CFG_CERT_FILE=server.crt CFG_KEY= CFG_KEY_FILE=server.key 
ENV CFG_DOMAIN=
ENV CFG_USER= CFG_PASS=
ENV CFG_CONFIG= CFG_CONFIG_FILE= CFG_CONFIG_URL=
ENV CFG_TEST=
ENV CFG_NFS_MOUNT=

ENTRYPOINT ["/bin/sh", "-c", "/usr/local/bin/startup.sh"]

