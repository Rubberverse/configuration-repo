# Didn't really work for chyrp-lite as it can't support proper path routing due to Caddy overcomplicating it.
# Seriously, why is it so damn hard to have something akin to php-fpm & nginx?

FROM docker.io/library/caddy:builder AS caddy-builder
FROM docker.io/dunglas/frankenphp:builder-alpine AS builder

COPY --from=caddy-builder /usr/bin/xcaddy /usr/bin/xcaddy

ENV CGO_ENABLED=1 \
    XCADDY_SETCAP=1 \
    XCADDY_GO_BUILD_FLAGS="-ldflags '-w -s'"

RUN xcaddy build                                             \
    --output /usr/local/bin/frankenphp                       \
    --with github.com/dunglas/frankenphp=./                  \
    --with github.com/dunglas/frankenphp/caddy=./caddy/      \
    --with github.com/dunglas/caddy-cbrotli                  \
    --with github.com/caddy-dns/cloudflare                   \
    --with github.com/hslatman/caddy-crowdsec-bouncer/http   \
    --with github.com/hslatman/caddy-crowdsec-bouncer/layer4 \
    --with github.com/corazawaf/coraza-caddy/v2              \
    --with github.com/jonaharagon/caddy-umami

FROM docker.io/dunglas/frankenphp:1.2-php8.3-alpine AS runtime

ARG CONT_UID=1001 \
    CONT_USR="web-data" \
    CONT_SHL="/bin/sh"

RUN install-php-extensions \
    gd \
    bz2 \
    zip \
    xml \
    intl \
    curl \
    json \
    mcrypt \
    bcmath \
    sqlite3 \
    opcache \
    enchant \
    mbstring \
    tokenizer \
    pdo_mysql \
    pdo_pgsql \
    && adduser \
        --home "/app" \
        --shell ${CONT_SHL} \
        --uid ${CONT_UID} \
        --disabled-password \
        --no-create-home \
        ${CONT_USR} \
    && mkdir -p /app/logs /srv/www \
    && chown -R ${CONT_UID}:${CONT_UID} /app /srv/www

COPY --from=builder /usr/local/bin/frankenphp /usr/local/bin/frankenphp

USER ${CONT_UID}