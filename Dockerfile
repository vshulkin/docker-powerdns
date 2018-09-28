# Stick to libressl 2.6
# https://github.com/PowerDNS/pdns/issues/6943
FROM alpine:3.7
MAINTAINER Christoph Wiechert <wio@psitrax.de>

ENV REFRESHED_AT="2018-09-09" \
    POWERDNS_VERSION=4.1.4 \
    MYSQL_AUTOCONF=true \
    MYSQL_HOST="mysql" \
    MYSQL_PORT="3306" \
    MYSQL_USER="root" \
    MYSQL_PASS="root" \
    MYSQL_DB="pdns"

# alpine:3.8: mariadb-connector-c-dev

RUN apk --update add libpq bash sqlite-libs libstdc++ libgcc mariadb-client mariadb-client-libs && \
    apk add --virtual build-deps \
      g++ make mariadb-dev postgresql-dev sqlite-dev curl boost-dev && \
    curl -sSL https://downloads.powerdns.com/releases/pdns-$POWERDNS_VERSION.tar.bz2 | tar xj -C /tmp && \
    cd /tmp/pdns-$POWERDNS_VERSION && \
    ./configure --prefix="" --exec-prefix=/usr --sysconfdir=/etc/pdns \
      --with-modules="bind gmysql gpgsql gsqlite3" --without-lua && \
    make && make install-strip && cd / && \
    mkdir -p /etc/pdns/conf.d && \
    addgroup -S pdns 2>/dev/null && \
    adduser -S -D -H -h /var/empty -s /bin/false -G pdns -g pdns pdns 2>/dev/null && \
    apk del --purge build-deps && \
    rm -rf /tmp/pdns-$POWERDNS_VERSION /var/cache/apk/*

ADD xip-pdns /xip-pdns
ADD xip-pdns.conf /etc/pdns/conf.d/
ADD schema.sql pdns.conf /etc/pdns/
ADD entrypoint.sh /

EXPOSE 53/tcp 53/udp

ENTRYPOINT ["/entrypoint.sh"]
