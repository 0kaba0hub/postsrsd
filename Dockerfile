FROM alpine:3.23 AS builder
RUN apk add --no-cache \
    cmake make gcc g++ musl-dev \
    autoconf automake libtool \
    libconfuse-dev \
    hiredis-dev \
    sqlite-dev \
    libseccomp-dev \
    git ca-certificates
WORKDIR /src
COPY . .
RUN mkdir _build && cd _build && \
    cmake .. \
      -DCMAKE_BUILD_TYPE=MinSizeRel \
      -DBUILD_TESTING=OFF \
      -DWITH_SQLITE=ON \
      -DWITH_REDIS=ON \
      -DWITH_MILTER=ON \
      -DWITH_SECCOMP=ON \
      -DGENERATE_SRS_SECRET=OFF \
      -DINSTALL_SYSTEMD_SERVICE=OFF \
      -DINSTALL_SYSTEMD_SYSUSERS=OFF && \
    make && make install DESTDIR=/install

FROM alpine:3.23
RUN apk add --no-cache \
    ca-certificates \
    libconfuse \
    hiredis \
    sqlite-libs \
    libseccomp
COPY --from=builder /install/usr/local/sbin/postsrsd /usr/local/sbin/postsrsd
COPY docker/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh /usr/local/sbin/postsrsd
EXPOSE 10003
ENTRYPOINT ["/entrypoint.sh"]
