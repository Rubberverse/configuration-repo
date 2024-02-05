FROM --platform=$BUILDPLATFORM golang:alpine AS builder

ARG TARGETARCH
ARG TARGETOS

ENV GOARCH $TARGETARCH 
ENV GOOS $TARGETOS
ENV GO111MODULE=on

ARG ALPINE_REPO_URL=https://dl-cdn.alpinelinux.org/alpine
ARG ALPINE_REPO_VERSION=v3.19
ARG CGO_ENABLED=on
ARG REMOTE_REPOSITORY=https://github.com/fatedier/frp.git
ARG BRANCH_TAG_NAME=v0.53.2

RUN apk add --no-cache --virtual build-deps --repository=${ALPINE_REPO_URL}/${ALPINE_REPO_VERSION}/main \
        git           \
        build-base    \
        libcap        \
        libcap-setcap \
    && git clone --branch ${BRANCH_TAG_NAME} ${REMOTE_REPOSITORY}; cd frp \
    && go build -v -a -trimpath -ldflags "-s -w" -o bin/frps ./cmd/frps \
    && go build -v -a -trimpath -ldflags "-s -w" -o bin/frpc ./cmd/frpc \
    && mv bin/frpc /usr/bin/frpc; mv bin/frps /usr/bin/frps \
    && setcap 'cap_net_bind_service+ep' /usr/bin/frps; setcap 'cap_net_bind_service+ep' /usr/bin/frpc \
    && apk del --rdepends \
        build-deps

FROM --platform=$TARGETPLATFORM docker.io/library/alpine:edge AS frpcs-entrypoint

ARG ALPINE_REPO_URL=https://dl-cdn.alpinelinux.org/alpine
ARG ALPINE_REPO_VERSION=edge
ARG CONT_UID=1001
ARG CONT_USER=frp

COPY --from=builder --chmod=0755 /usr/bin/frps /usr/bin/frps
COPY --from=builder --chmod=0755 /usr/bin/frpc /usr/bin/frpc
COPY --chmod=0755 scripts/docker-entrypoint.sh /app/scripts/docker-entrypoint.sh

RUN apk upgrade --no-cache; apk add --no-cache --repository=${ALPINE_REPO_URL}/${ALPINE_REPO_VERSION}/main \
        openssl \
    && adduser \
        --home "/app"       \
        --shell "/bin/ash"  \
        --uid "$CONT_UID"   \
        --disabled-password \
        --no-create-home    \
        "$CONT_USER"

USER "${CONT_UID}"

ENTRYPOINT /app/scripts/docker-entrypoint.sh
