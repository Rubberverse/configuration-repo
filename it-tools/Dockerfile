FROM node:lts-alpine AS build-stage

ENV NPM_CONFIG_LOGLEVEL warn
ENV CI true

WORKDIR /app
COPY package.json pnpm-lock.yaml ./
RUN npm install -g pnpm && pnpm i --frozen-lockfile
COPY . .
RUN pnpm build

FROM nginx:stable-alpine AS production-stage
COPY --from=build-stage /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

RUN addgroup \
        --system \
        --gid 1001 \
        nginx_user \
    && adduser \
        --home "/var/lib/mysql" \
        --shell "/bin/sh" \
        --uid 1001 \
        --ingroup nginx_user \
        --disabled-password \
        nginx_user \
    && touch /run/nginx.pid \
    && chown -Rf nginx_user:nginx_user \
        /var/cache/nginx \
        /var/log/nginx \
        /etc/nginx \
    && chown nginx_user:nginx_user \
        /run/nginx.pid

USER nginx_user
CMD ["nginx", "-g", "daemon off;"]
