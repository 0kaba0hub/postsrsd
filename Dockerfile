FROM ubuntu:24.04 AS builder
RUN apt-get update -qq && apt-get install -y --no-install-recommends \
    cmake make gcc musl-dev musl-tools dpkg-dev gperf git \
    libconfuse-dev libhiredis-dev libsqlite3-dev libseccomp-dev \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*
WORKDIR /src
COPY . .
RUN mkdir _build && cd _build && \
    cmake .. \
      -DCMAKE_BUILD_TYPE=MinSizeRel \
      -DCMAKE_C_COMPILER=musl-gcc \
      -DCMAKE_EXE_LINKER_FLAGS=-static \
      -DCMAKE_C_FLAGS="-idirafter /usr/include -idirafter /usr/include/$(dpkg-architecture -qDEB_HOST_MULTIARCH)" \
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
RUN apk add --no-cache ca-certificates
COPY --from=builder /install/usr/local/sbin/postsrsd /usr/local/sbin/postsrsd
COPY docker/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh /usr/local/sbin/postsrsd
EXPOSE 10003
ENTRYPOINT ["/entrypoint.sh"]
