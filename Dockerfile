FROM ubuntu:22.04 AS builder

ARG EXONERATE_REPO=https://github.com/nathanweeks/exonerate.git
ARG EXONERATE_REF=v2.4.0

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        autoconf \
        automake \
        ca-certificates \
        gcc \
        git \
        libglib2.0-dev \
        make \
        pkg-config \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /tmp
RUN git clone --depth 1 --branch "${EXONERATE_REF}" "${EXONERATE_REPO}" exonerate-src

WORKDIR /tmp/exonerate-src
RUN autoreconf -i \
    && ./configure --prefix=/usr/local \
    && make -j"$(nproc)" \
    && make install DESTDIR=/out

FROM ubuntu:22.04

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /out/usr/local /usr/local

RUN printf '%s\n' \
    '#!/usr/bin/env bash' \
    'set -euo pipefail' \
    'if [ "$#" -gt 0 ] && [ "$1" = "exonerate" ]; then' \
    '  shift' \
    'fi' \
    'exec /usr/local/bin/exonerate "$@"' \
    > /usr/local/bin/entrypoint \
    && chmod +x /usr/local/bin/entrypoint

WORKDIR /data
ENTRYPOINT ["/usr/local/bin/entrypoint"]
