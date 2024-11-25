FROM    docker.io/library/rust:1.79.0-alpine3.20 AS compiler

RUN     apk add -q --no-cache build-base openssl-dev

WORKDIR /

ARG     COMMIT_SHA
ARG     COMMIT_DATE
ARG     GIT_TAG
ENV     VERGEN_GIT_SHA=${COMMIT_SHA} VERGEN_GIT_COMMIT_TIMESTAMP=${COMMIT_DATE} VERGEN_GIT_DESCRIBE=${GIT_TAG}
ENV     RUSTFLAGS="-C target-feature=-crt-static"

COPY    . .
RUN     set -eux; \
        apkArch="$(apk --print-arch)"; \
        if [ "$apkArch" = "aarch64" ]; then \
            export JEMALLOC_SYS_WITH_LG_PAGE=16; \
        fi && \
        cargo build --release -p meilisearch -p meilitool

FROM    docker.io/library/alpine:edge
LABEL   org.opencontainers.image.source="https://github.com/meilisearch/meilisearch"

ARG     CONT_USER=meilisearch
ARG     CONT_UID=1001

ENV     MEILI_HTTP_ADDR 0.0.0.0:7700
ENV     MEILI_SERVER_PROVIDER docker
        # TINI can't reap processes when not as UID=1 so we are making use of SUBREAPER instead
ENV     TINI_SUBREAPER=1

COPY    --chmod=755 --from=compiler /target/release/meilisearch /bin/meilisearch
COPY    --chmod=755 --from=compiler /target/release/meilitool /bin/meilitool

RUN     apk update \
            && apk upgrade --no-cache \
            && apk add -q --no-cache libgcc tini curl \
            && addgroup \
                --system \
                --gid ${CONT_UID} \
                ${CONT_USER} \
            && adduser \
                --home "/meili_data" \
                --shell "/bin/sh" \
                --uid ${CONT_UID} \
                --ingroup ${CONT_USER} \
                --disabled-password \
                ${CONT_USER} \
            && mkdir -p meili_data \
            && chown -R ${CONT_USER}:${CONT_USER} meili_data \
            && ln -s /bin/meilisearch /meilisearch \
            && rm -rf /var/cache/apk/*

WORKDIR   /meili_data
USER      ${CONT_USER}

ENTRYPOINT ["tini", "--"]
CMD        /bin/meilisearch
