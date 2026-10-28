# syntax=docker/dockerfile:1
# Isolated f-refactor tools. The application tree is not part of this image.
ARG PHP_IMAGE=php@sha256:debadc2e36b857657846e2e952cbaf52702e55482dd3c2c43806f68d8c534a70
ARG COMPOSER_IMAGE=composer@sha256:5248900ab8b5f7f880c2d62180e40960cd87f60149ec9a1abfd62ac72a02577c

# Digest pin lives in the ARG default. A floating tag is intentionally not the default.
# hadolint ignore=DL3006
FROM ${COMPOSER_IMAGE} AS composer_bin

# hadolint ignore=DL3006
FROM ${PHP_IMAGE}

ARG COMPOSER_REPO=https://repo.packagist.org

USER root
# Packages follow the Debian snapshot of the pinned php image. Versions move with that digest.
# hadolint ignore=DL3008
RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates unzip \
    && rm -rf /var/lib/apt/lists/* \
    && groupadd --gid 10001 toolchain \
    && useradd --uid 10001 --gid 10001 --create-home --home-dir /home/toolchain --shell /usr/sbin/nologin toolchain \
    && mkdir -p /opt/toolchain /out \
    && chown toolchain:toolchain /opt/toolchain /out

COPY --from=composer_bin /usr/bin/composer /usr/local/bin/composer

WORKDIR /opt/toolchain
COPY --chown=toolchain:toolchain composer.json composer.lock lib.sh image-install.sh entry.sh /opt/toolchain/

USER toolchain
ENV COMPOSER_HOME=/tmp/composer \
    COMPOSER_NO_INTERACTION=1 \
    COMPOSER_REPO=${COMPOSER_REPO} \
    HOME=/tmp \
    PATH=/opt/toolchain/vendor/bin:/usr/local/bin:/usr/bin:/bin \
    TMPDIR=/tmp

RUN --mount=type=secret,id=composer_auth,required=false \
    bash /opt/toolchain/image-install.sh \
    && rm -rf /tmp/composer

WORKDIR /app
ENTRYPOINT ["bash", "/opt/toolchain/entry.sh"]
