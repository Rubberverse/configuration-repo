FROM node:22.13.1-bullseye-slim AS base

FROM base AS builder
ENV DEBIAN_FRONTEND=noninteractive
RUN apt update \
    && apt upgrade -y

# Set working directory
WORKDIR /app
RUN apt install -y curl bash
RUN apt update
RUN apt upgrade
COPY . .

RUN corepack enable pnpm && pnpm install --recursive --frozen-lockfile

# Copy static data as it is not part of the build
COPY static-data ./static-data
ARG SKIP_ENV_VALIDATION='true'
ARG CI='true'
ARG DISABLE_REDIS_LOGS='true'
RUN corepack enable pnpm && pnpm build

FROM base AS runner
WORKDIR /app
ARG CONT_USER=homarr
ARG CONT_UID=1001

# gettext is required for envsubst, openssl for generating AUTH_SECRET, su-exec for running application as non-root
RUN apt update
RUN apt upgrade -y
RUN apt install -y redis bash openssl
RUN mkdir /appdata
VOLUME /appdata

# Enable homarr cli
COPY --from=builder /app/packages/cli/cli.cjs /app/apps/cli/cli.cjs
RUN echo $'#!/bin/bash\ncd /app/apps/cli && node ./cli.cjs "$@"' > /usr/bin/homarr
RUN chmod +x /usr/bin/homarr
RUN rm -rf /var/cache/apt \
    && adduser \
       --home "/appdata" \
       --shell "/bin/false" \
       --uid "$CONT_UID" \
       --disabled-password \
       --no-create-home \
       "$CONT_USER"

COPY --from=builder /app/apps/nextjs/next.config.ts .
COPY --from=builder /app/apps/nextjs/package.json .
COPY --from=builder /app/apps/tasks/tasks.cjs ./apps/tasks/tasks.cjs
COPY --from=builder /app/apps/websocket/wssServer.cjs ./apps/websocket/wssServer.cjs
COPY --from=builder /app/node_modules/better-sqlite3/build/Release/better_sqlite3.node /app/build/better_sqlite3.node
COPY --from=builder /app/packages/db/migrations ./db/migrations
COPY --from=builder /app/apps/nextjs/.next/standalone ./
COPY --from=builder /app/apps/nextjs/.next/static ./apps/nextjs/.next/static
COPY --from=builder /app/apps/nextjs/public ./apps/nextjs/public
COPY packages/redis/redis.conf /app/redis.conf

ENV DB_URL='/appdata/db/db.sqlite'
ENV DB_DIALECT='sqlite'
ENV DB_DRIVER='better-sqlite3'
ENV AUTH_PROVIDERS='credentials'

USER $CONT_USER
ENTRYPOINT [ "/app/scripts/run.sh" ]
