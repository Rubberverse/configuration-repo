# Seperate layer sourcing git repository
FROM debian:bookworm-slim AS source-code
ARG GIT_REMOTE_TAG
ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /app
RUN apt update \
    && apt install git curl -y \
    && rm -rf /var/apt/cache \
    && git clone https://github.com/umami-software/umami -b $GIT_REMOTE_TAG .

# Install dependencies only when needed
FROM node:18-bookworm AS deps
WORKDIR /app

ENV DEBIAN_FRONTEND=noninteractive

COPY --from=source-code /app/package.json /app/yarn.lock ./

# Add yarn timeout to handle slow CPU when Github Actions
RUN yarn config set network-timeout 300000
# [husky] Stop installation from failing due to non-existent .git folder
RUN git init
RUN yarn install --frozen-lockfile

# Rebuild the source code only when needed
FROM node:18-bookworm AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY --from=source-code /app .
COPY --from=source-code /app/docker/middleware.js ./src

ARG DATABASE_TYPE="postgresql"
ARG BASE_PATH

ENV DATABASE_TYPE $DATABASE_TYPE
ENV BASE_PATH $BASE_PATH

ENV NEXT_TELEMETRY_DISABLED 1

RUN yarn build-docker

# Production image, copy all the files and run next
FROM node:18-bookworm AS runner
WORKDIR /app

ENV DEBIAN_FRONTEND=noninteractive
ENV NODE_ENV production
ENV NEXT_TELEMETRY_DISABLED 1

RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

RUN set -x \
    && apt update \
    && apt upgrade -y \
    && apt install curl openssl -y \
    && rm -rf /var/apt/cache \
    && yarn add npm-run-all dotenv semver prisma@5.17.0

# You only need to copy next.config.js if you are NOT using the default configuration
COPY --from=builder /app/next.config.js .
COPY --from=builder --chown=nextjs:nodejs /app/public ./public
COPY --from=builder /app/package.json ./package.json
COPY --from=builder /app/prisma ./prisma
COPY --from=builder /app/scripts ./scripts

# Automatically leverage output traces to reduce image size
# https://nextjs.org/docs/advanced-features/output-file-tracing
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

USER nextjs

ENV HOSTNAME 0.0.0.0
ENV PORT 3000

CMD ["yarn", "start-docker"]
