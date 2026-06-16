#!/bin/sh
set -e

DOMAIN="${SRS_DOMAIN:-example.com}"
SECRET="${SRS_SECRET:-changeme}"
PORT="${SRS_PORT:-10003}"

install -m 600 /dev/null /run/postsrsd.secret
printf '%s\n' "${SECRET}" > /run/postsrsd.secret

cat > /etc/postsrsd.conf <<CONF
domains = { "${DOMAIN}" }
secrets-file = "/run/postsrsd.secret"
socketmap = inet:0.0.0.0:${PORT}
chroot-dir = ""
unprivileged-user = ""
seccomp = off
CONF

exec /usr/local/sbin/postsrsd
