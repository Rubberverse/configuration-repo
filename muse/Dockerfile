ARG IMAGE_REPOSITORY=docker.io/library
ARG IMAGE_NODE_VERSION=18-bookworm-slim

# ==================================================== #
# Base image
# ==================================================== #
FROM $IMAGE_REPOSITORY/node:$IMAGE_NODE_VERSION AS debian-base

ENV DEBIAN_FRONTEND=noninteractive
WORKDIR /usr/app

RUN apt update \
    && apt upgrade -y \
    && apt install --no-install-recommends -y \
        adduser \
        ffmpeg \
        openssl \
        ca-certificates

# ==================================================== #
# Builds out actual project
# ==================================================== #
FROM debian-base AS debian-builder

WORKDIR /usr/app

ARG GIT_REPOSITORY=https://github.com/museofficial/muse.git \
    GIT_BRANCH=master \
    GIT_WORKTREE=/app/worktree \
    npm_config_cache=/app/.cache

RUN apt install --no-install-recommends -y \
    git libc6-dev gcc g++ dpkg-dev make python3 \
    && git config --global --add safe.directory '*' \
    && git clone -b ${GIT_BRANCH} ${GIT_REPOSITORY} muse \
    && git clone -b ${GIT_BRANCH} ${GIT_REPOSITORY} muse-untouched \
    && cd muse \
    && yarn install --prod \
    && cp -R node_modules /usr/app/prod_node_modules \
    && yarn install \
    && yarn prisma generate \
    && yarn build \
    && yarn cache clean \
    && apt remove git libc6-dev gcc g++ dpkg-dev make python3 -y \
    && apt autoremove -y \
    && rm -rf /app/worktree /var/lib/apt /usr/app/muse/.git /app/.cache

# ==================================================== #
# Container runner
# ==================================================== #
FROM debian-base AS debian-runner

WORKDIR /app

ARG CONT_USER=muse \
    CONT_SHELL=/bin/sh \
    CONT_UID=1001

COPY --from=debian-builder /usr/app/muse-untouched /app
COPY --from=debian-builder /usr/app/muse/dist dist
COPY --from=debian-builder /usr/app/prod_node_modules node_modules
COPY --from=debian-builder /usr/app/muse/node_modules/.prisma/client node_modules/.prisma/client

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
    NODE_ENV=production \
    DEBIAN_FRONTEND=noninteractive

USER ${CONT_USER}

ENTRYPOINT ["node", "--enable-source-maps", "/app/dist/scripts/migrate-and-start.js"]
