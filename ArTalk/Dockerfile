FROM docker.io/golang:alpine AS builder

WORKDIR /source
ARG SKIP_UI_BUILD=false

RUN apk update \
    && apk upgrade --no-cache \
    && apk add --no-cache --virtual build_ess \
        git \
        gcc \
        make \
        bash \
        musl-dev

COPY go.mod go.sum ./
RUN go mod download

COPY . .

RUN set -ex \
    && if [ "$SKIP_UI_BUILD" = "false" ]; then \
        apk add --no-cache nodejs npm \
        && npm install -g pnpm@9.10.0 \
    ;fi

RUN set -ex \
    && if [ "$SKIP_UI_BUILD" = "false" ]; then \
        make build-frontend \
    ;fi

ARG APP_VERSION="v2.9.1"
ARG APP_COMMIT_HASH="0627e04a673af213a2c00d78a7509b38f67d64ec"

RUN set -ex \
    && if [[ ! -z "$APP_VERSION" ]]; then export VERSION=$APP_VERSION ;fi \
    && if [[ ! -z "$APP_COMMIT_HASH" ]]; then export COMMIT_HASH=$APP_COMMIT_HASH ;fi \
    && make build

FROM docker.io/alpine:edge

ARG TZ="Europe/Warsaw"
ARG CONT_USER=artalk
ARG CONT_UID=1001
ENV TZ=${TZ}

COPY --from=builder /source/bin/artalk /artalk
COPY --chmod=755 scripts/docker-artalk-runner.sh /usr/bin/artalk
COPY --chmod=755 docker-entrypoint.sh /entrypoint.sh

RUN apk update \
    && apk upgrade --no-cache \
    && apk add --no-cache \
        tzdata \
    && ln -sf /usr/share/zoneinfo/${TZ} /etc/localtime \
    && echo ${TZ} > /etc/timezone \
    && rm -rf /var/cache/apk/* \
    && addgroup \
        --system \
        --gid ${CONT_UID} \
        ${CONT_USER} \
    && adduser \
        --home "/data" \
        --shell "/bin/sh" \
        --uid ${CONT_UID} \
        --ingroup ${CONT_USER} \
        --disabled-password \
        ${CONT_USER} \
    && ln -s /usr/bin/artalk /usr/bin/artalk-go \
    && mkdir -p /data \
    && chown -R ${CONT_USER}:${CONT_USER} /data

WORKDIR /data
USER ${CONT_USER}
ENTRYPOINT ["/entrypoint.sh"]
CMD ["server", "--host", "0.0.0.0", "--port", "9006"]
