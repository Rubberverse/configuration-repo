# syntax = docker/dockerfile:1.4

ARG NODE_VERSION=22.11.0-bookworm-slim

FROM node:${NODE_VERSION} as build

ENV PYTHONUNBUFFERED=1
RUN apt update \
        && apt upgrade -y --no-install-recommends \
        && apt install -y --no-install-recommends linux-headers-amd64 build-essential python3 python3-pip python3-setuptools git \
        && ln -sf python3 /usr/bin/python

RUN corepack enable

WORKDIR /sharkey

COPY . ./

RUN git submodule update --init --recursive
RUN pnpm config set fetch-retries 5
RUN --mount=type=cache,target=/root/.local/share/pnpm/store,sharing=locked \
        pnpm i --frozen-lockfile --aggregate-output
RUN pnpm build
RUN node scripts/trim-deps.mjs
RUN mv packages/frontend/assets sharkey-assets
RUN mv packages/frontend-embed/assets sharkey-embed-assets
RUN --mount=type=cache,target=/root/.local/share/pnpm/store,sharing=locked \
        pnpm prune
RUN rm -r node_modules packages/frontend packages/frontend-shared packages/frontend-embed packages/sw
RUN --mount=type=cache,target=/root/.local/share/pnpm/store,sharing=locked \
        pnpm i --prod --frozen-lockfile --aggregate-output
RUN rm -rf .git

FROM node:${NODE_VERSION}

ARG UID="1001"
ARG GID="1001"

RUN apt update \
        && apt upgrade -y --no-install-recommends \
        && apt install -y --no-install-recommends ffmpeg tini libjemalloc2 tar \
        && corepack enable \
        && addgroup --gid ${GID} sharkey \
        && adduser --uid ${GID} --shell /bin/sh --ingroup sharkey --disabled-login --disabled-password sharkey --home /sharkey \
        && mkdir /sharkey/files \
        && chown -R sharkey:sharkey /sharkey/files \
        && find / -type d -path /sys -prune -o -type d -path /proc -prune -o -type f -perm /u+s -exec chmod u-s {} \; \
        && find / -type d -path /sys -prune -o -type d -path /proc -prune -o -type f -perm /g+s -exec chmod g-s {} \; \
        && rm -rf /var/cache/apt/*

USER sharkey
WORKDIR /sharkey

# add package.json to add pnpm
COPY --chown=sharkey:sharkey ./package.json ./package.json
RUN corepack install

COPY --chown=sharkey:sharkey --from=build /sharkey/node_modules ./node_modules
COPY --chown=sharkey:sharkey --from=build /sharkey/packages/backend/node_modules ./packages/backend/node_modules
COPY --chown=sharkey:sharkey --from=build /sharkey/packages/misskey-js/node_modules ./packages/misskey-js/node_modules
COPY --chown=sharkey:sharkey --from=build /sharkey/packages/misskey-reversi/node_modules ./packages/misskey-reversi/node_modules
COPY --chown=sharkey:sharkey --from=build /sharkey/packages/misskey-bubble-game/node_modules ./packages/misskey-bubble-game/node_modules
COPY --chown=sharkey:sharkey --from=build /sharkey/packages/megalodon/node_modules ./packages/megalodon/node_modules
COPY --chown=sharkey:sharkey --from=build /sharkey/built ./built
COPY --chown=sharkey:sharkey --from=build /sharkey/packages/misskey-js/built ./packages/misskey-js/built
COPY --chown=sharkey:sharkey --from=build /sharkey/packages/misskey-reversi/built ./packages/misskey-reversi/built
COPY --chown=sharkey:sharkey --from=build /sharkey/packages/misskey-bubble-game/built ./packages/misskey-bubble-game/built
COPY --chown=sharkey:sharkey --from=build /sharkey/packages/backend/built ./packages/backend/built
COPY --chown=sharkey:sharkey --from=build /sharkey/packages/megalodon/lib ./packages/megalodon/lib
COPY --chown=sharkey:sharkey --from=build /sharkey/fluent-emojis ./fluent-emojis
COPY --chown=sharkey:sharkey --from=build /sharkey/tossface-emojis/dist ./tossface-emojis/dist
COPY --chown=sharkey:sharkey --from=build /sharkey/sharkey-assets ./packages/frontend/assets
COPY --chown=sharkey:sharkey --from=build /sharkey/sharkey-embed-assets ./packages/frontend-embed/assets

COPY --chown=sharkey:sharkey pnpm-workspace.yaml ./pnpm-workspace.yaml
COPY --chown=sharkey:sharkey packages/backend/package.json ./packages/backend/package.json
COPY --chown=sharkey:sharkey packages/backend/scripts/check_connect.js ./packages/backend/scripts/check_connect.js
COPY --chown=sharkey:sharkey packages/backend/ormconfig.js ./packages/backend/ormconfig.js
COPY --chown=sharkey:sharkey packages/backend/migration ./packages/backend/migration
COPY --chown=sharkey:sharkey packages/backend/assets ./packages/backend/assets
COPY --chown=sharkey:sharkey packages/megalodon/package.json ./packages/megalodon/package.json
COPY --chown=sharkey:sharkey packages/misskey-js/package.json ./packages/misskey-js/package.json
COPY --chown=sharkey:sharkey packages/misskey-reversi/package.json ./packages/misskey-reversi/package.json
COPY --chown=sharkey:sharkey packages/misskey-bubble-game/package.json ./packages/misskey-bubble-game/package.json

ENV LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libjemalloc.so.2
ENV NODE_ENV=production
ENTRYPOINT ["tini", "--"]
CMD ["pnpm", "run", "migrateandstart"]


