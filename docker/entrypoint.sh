#!/bin/sh
set -e

DOMAIN="${SRS_DOMAIN:-example.com}"
SECRET="${SRS_SECRET:-changeme}"
MILTER_PORT="${SRS_MILTER_PORT:-10001}"
SOCKETMAP_PORT="${SRS_SOCKETMAP_PORT:-10003}"

install -m 600 /dev/null /run/postsrsd.secret
printf '%s\n' "${SECRET}" > /run/postsrsd.secret

cat > /etc/postsrsd.conf <<CONF
domains = { "${DOMAIN}" }
secrets-file = "/run/postsrsd.secret"
milter = inet:0.0.0.0:${MILTER_PORT}
socketmap = inet:0.0.0.0:${SOCKETMAP_PORT}
chroot-dir = ""
unprivileged-user = ""
seccomp = off
CONF

exec /usr/local/sbin/postsrsd
