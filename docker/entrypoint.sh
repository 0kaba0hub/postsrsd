#!/bin/sh
set -e

DOMAIN="${SRS_DOMAIN:-example.com}"
SECRET="${SRS_SECRET:-changeme}"
MILTER_PORT="${SRS_MILTER_PORT:-10001}"
SOCKETMAP_PORT="${SRS_SOCKETMAP_PORT:-10003}"
REDIS_ADDR="${SRS_REDIS_ADDR:-}"
DEBUG="${SRS_DEBUG:-off}"

install -m 600 /dev/null /run/postsrsd.secret
printf '%s\n' "${SECRET}" > /run/postsrsd.secret

mkdir -p /usr/local/etc
cat > /usr/local/etc/postsrsd.conf <<CONF
domains = { "${DOMAIN}" }
secrets-file = "/run/postsrsd.secret"
milter = inet:0.0.0.0:${MILTER_PORT}
socketmap = inet:0.0.0.0:${SOCKETMAP_PORT}
chroot-dir = ""
unprivileged-user = ""
seccomp = off
debug = ${DEBUG}
CONF

if [ -n "${REDIS_ADDR}" ]; then
    printf 'envelope-database = "redis:%s"\n' "${REDIS_ADDR}" >> /usr/local/etc/postsrsd.conf
fi

exec /usr/local/sbin/postsrsd
