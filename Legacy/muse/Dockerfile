ARG IMAGE_REPOSITORY=docker.io/library
ARG IMAGE_NODE_VERSION=18-bookworm-slim

# ==================================================== #
# Builds out actual project
# ==================================================== #
FROM $IMAGE_REPOSITORY/node:$IMAGE_NODE_VERSION AS debian-builder

WORKDIR /usr/app/muse

ARG GIT_REPOSITORY=https://github.com/museofficial/muse.git \
    GIT_BRANCH=master \
    GIT_WORKTREE=/root/worktree \
    npm_config_cache=/root/.cache

RUN apt update \
    && apt install --no-install-recommends -y \
        git \
        gcc \ 
        g++ \
        make \
        python3 \
        dpkg-dev \
        libc6-dev \
        ca-certificates \
    && git config --global --add safe.directory '*' \
    && git clone -b ${GIT_BRANCH} ${GIT_REPOSITORY} . \
    && yarn install --prod \
    && cp -R node_modules /root/node_modules \
    && yarn install \
    && yarn prisma generate \
    && yarn build \
    && yarn cache clean \
    && mv \
        node_modules/.prisma/client /root/prisma \
    && mv \
        dist /root/dist \
    && rm -rf \
        node_modules \
    && apt remove --auto-remove -y \
        git \
        gcc \
        g++ \
        make \
        python3 \
        dpkg-dev \
        libc6-dev \
    && rm -rf \
        /root/worktree \
        /var/lib/apt \
        /usr/app/muse/.git \
        /root/.cache

# ==================================================== #
# Container runner
# ==================================================== #
FROM $IMAGE_REPOSITORY/node:$IMAGE_NODE_VERSION AS debian-runner

WORKDIR /app

ARG CONT_USER=muse \
    CONT_SHELL=/bin/sh \
    CONT_UID=1001

ENV DEBIAN_FRONTEND=noninteractive \
    DATA_DIR=/app/data \
    NODE_ENV=production \
    TINI_SUBREAPER=1

COPY --from=debian-builder /usr/app/muse /app
COPY --from=debian-builder /root/dist dist
COPY --from=debian-builder /root/node_modules node_modules
COPY --from=debian-builder /root/prisma node_modules/.prisma/client

RUN apt update \
    && apt upgrade -y \
    && apt install --no-install-recommends -y \
        ffmpeg \
        openssl \
        ca-certificates \
        tini \
    && adduser \
        --home "/app" \
        --shell "$CONT_SHELL" \
        --uid "$CONT_UID" \
        --disabled-password \
        --no-create-home \
        "$CONT_USER" \
    && mkdir -p /app/data \
    && chown -R $CONT_USER /app/data

USER ${CONT_USER}

ENTRYPOINT ["tini", "--", "node", "--enable-source-maps", "/app/dist/scripts/migrate-and-start.js"]
