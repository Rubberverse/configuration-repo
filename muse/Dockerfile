# =-=-=-=-=-=-=-=-=
# Base Stage
# =-=-=-=-=-=-=-=-=
# Rootless Dockerfile running https://github.com/museofficial/muse
# Size reduction: eventually lol

ARG IMAGE_REPOSITORY=docker.io/library
ARG IMAGE_ALPINE_VERSION=18-alpine3.20

FROM $IMAGE_REPOSITORY/node:$IMAGE_ALPINE_VERSION AS alpine-base

ARG ALPINE_REPO_URL=https://dl-cdn.alpinelinux.org/alpine \
    ALPINE_REPO_VERSION=v3.20

WORKDIR /usr/app

RUN apk update \
    && apk upgrade --no-cache \
    && apk add --no-cache --repository=${ALPINE_REPO_URL}/${ALPINE_REPO_VERSION}/main \
        tini \
        ffmpeg \
        openssl \
        ca-certificates \
    && rm -rf /var/cache/apk

# =-=-=-=-=-=-=-=-=
# Builder Stage
# =-=-=-=-=-=-=-=-=

FROM alpine-base AS alpine-builder

WORKDIR /usr/app

ARG ALPINE_REPO_URL=https://dl-cdn.alpinelinux.org/alpine \
    ALPINE_REPO_VERSION=v3.20 \
    GIT_REPOSITORY=https://github.com/museofficial/muse.git \
    GIT_BRANCH=master \
    GIT_WORKTREE=/app/worktree

RUN apk add --no-cache --virtual build_ess --repository=${ALPINE_REPO_URL}/${ALPINE_REPO_VERSION}/main \
    git curl python3 build-base yarn \
    # ============================================= #
    && git config --global --add safe.directory '*' \
    && git clone -b ${GIT_BRANCH} ${GIT_REPOSITORY} \
    && cd muse \
    # ============================================= #
    && yarn install --prod \
    && cp -R node_modules /usr/app/prod_node_modules \
    && yarn install \
    && yarn prisma generate \
    && yarn build \
    && apk del build_ess \
    && rm -vrf /app/worktree /var/cache/apk

# =-=-=-=-=-=-=-=-=
# Runner Stage
# =-=-=-=-=-=-=-=-=

FROM alpine-base AS alpine-runner

WORKDIR /app

ARG CONT_USER=muse \
    CONT_SHELL=/bin/sh \
    CONT_UID=1001

RUN adduser \
    --home "/app" \
    --shell "$CONT_SHELL" \
    --uid "$CONT_UID" \
    --disabled-password \
    --no-create-home \
    "$CONT_USER" \
    && mkdir -p /app/data

COPY --from=alpine-builder --chown=$CONT_USER /usr/app/muse /app

ENV DATA_DIR=/app/data \
    NODE_ENV=production

USER ${CONT_USER}

ENTRYPOINT ["tini", "--", "node", "--enable-source-maps", "/app/dist/scripts/migrate-and-start.js"]
