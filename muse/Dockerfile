# =-=-=-=-=-=-=-=-=
# Base Stage
# =-=-=-=-=-=-=-=-=

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
    GIT_WORKTREE=/app/worktree \

ENV npm_config_cache=/app/.cache

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
    && yarn cache clean \
    && apk del build_ess \
    && rm -rf /app/worktree /var/cache/apk /usr/app/muse/.git

# =-=-=-=-=-=-=-=-=
# Clean Pull Stage
# =-=-=-=-=-=-=-=-=

FROM alpine-base AS alpine-clean

WORKDIR /usr/app

ARG ALPINE_REPO_URL=https://dl-cdn.alpinelinux.org/alpine \
    ALPINE_REPO_VERSION=v3.20 \
    GIT_REPOSITORY=https://github.com/museofficial/muse.git \
    GIT_BRANCH=master

RUN apk add --no-cache --virtual build_ess --repository=${ALPINE_REPO_URL}/${ALPINE_REPO_VERSION}/main \
    git \
    # ============================================= #
    && git config --global --add safe.directory '*' \
    && git clone -b ${GIT_BRANCH} ${GIT_REPOSITORY} \
    # ============================================= #
    && apk del build_ess \
    && rm -rf \
        /app/worktree \
        /var/cache/apk \
        /usr/app/muse/.git \
        /usr/app/muse/.github \
    && rm \
        /usr/app/muse/*.md \
        /usr/app/muse/LICENSE \
        /usr/app/muse/Dockerfile

# =-=-=-=-=-=-=-=-=
# Runner Stage
# =-=-=-=-=-=-=-=-=

FROM alpine-base AS alpine-runner

WORKDIR /app

ARG CONT_USER=muse \
    CONT_SHELL=/bin/sh \
    CONT_UID=1001

COPY --from=alpine-clean /usr/app/muse /app
COPY --from=alpine-builder /usr/app/muse/dist dist
COPY --from=alpine-builder /usr/app/prod_node_modules node_modules
COPY --from=alpine-builder /usr/app/muse/node_modules/.prisma/client node_modules/.prisma/client

RUN adduser \
    --home "/app" \
    --shell "$CONT_SHELL" \
    --uid "$CONT_UID" \
    --disabled-password \
    --no-create-home \
    "$CONT_USER" \
    && mkdir -p /app/data \
    && chown -R $CONT_USER /app/data

ENV DATA_DIR=/app/data \
    NODE_ENV=production

USER ${CONT_USER}

ENTRYPOINT ["tini", "--", "node", "--enable-source-maps", "/app/dist/scripts/migrate-and-start.js"]
