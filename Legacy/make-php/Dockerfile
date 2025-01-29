##=======================================================================##
## MAKE SURE YOU HAVE ENOUGH SPACE ON YOUR STORAGE BEFORE RUNNING THIS   ##
## THIS COMPILES ENCHANT AND PHP {insert version here} FROM SOURCE       ##
## THE MORE RESOURCES YOU GOT TO SPARE, THE FASTER IT WILL BE            ##
##=======================================================================## 
## Bare minimum: 4GB of RAM, 10GB storage space left, 4 cores            ##
## Recommended: 16GB+ of RAM, 15GB or more storage left, 4 cores or more ##
##=======================================================================##
## This builds x86_64 binary and image. If you want something more, it's ##
## up to your own accord to modify this Dockerfile to your own liking to ##
## make that possible.                                                   ##
## ===================================================================== ##
## I threw this up at 3AM for no real reason - MrRubberDucky             ##

FROM docker.io/library/alpine:3.19.1

ARG ALPINE_VERSION=v3.19 \
    BRANCH_TAG=8.3.2

ARG BRANCH_TAG=8.3.2
ARG ENCHANT_TAG=2.6.6
ARG PKG_CONFIG_PATH=/usr/local:/usr/include:/usr/lib/pkgconfig:/usr/share/pkgconfig

# 800 Megajets to compile a project that will be 10MB in size, can we get much higherrrrrrrrrrr
RUN apk add --virtual build --no-cache --repository=https://dl-cdn.alpinelinux.org/alpine/v3.19/main \
    curl-dev libtool libbz2 zlib libzip-dev libffi-dev libpng-dev libwebp-dev jpeg-dev libwebp-dev libavif-dev libgmpxx libldap libssl3 libpq-dev libgccjit-dev \
    libsodium-dev libxml2-dev readline-dev gcc g++ make cmake pkgconf autoconf libtool bison re2c sqlite-dev curl zlib libcurl libbz2 oniguruma-dev \
    libc6-compat make gcc glib glib-dev groff icu icu-libs icu-dev icu-data-full mariadb mariadb-dev file libxpm-dev freetype-dev \
    && mkdir -p /etc/build \
    && cd /etc/build \
    # =============================================================================================================================
    # Enchant build
    && curl -Lo enchant.tar.gz https://github.com/AbiWord/enchant/releases/download/v${ENCHANT_TAG}/enchant-${ENCHANT_TAG}.tar.gz \
    && tar -xzvf enchant.tar.gz \
    && rm enchant.tar.gz \
    && cd enchant-${ENCHANT_TAG} \
    && ./configure CC=gcc CFLAGS=-g \
    && make; make install \
    && cd /etc/build \
    && rm -rf enchant-${ENCHANT_TAG} \
    # ==============================================================================================================================
    # PHP Build
    && curl -Lo php.tar.gz https://www.php.net/distributions/php-${BRANCH_TAG}.tar.gz \
    && tar -xzf php.tar.gz; rm php.tar.gz \
    && mv php-${BRANCH_TAG} php-src \
    && cd php-src \
    && ./buildconf \
    && ./configure --prefix=/etc/php8.3 \
        --enable-calendar \
        --enable-mbstring \
        --enable-sockets \
        --enable-opcache \
        --enable-bcmath \
        --enable-intl \
        --enable-exif \
        --enable-soap \
        --enable-session \
        --enable-mysqlnd \
        --enable-xml \
    # Enable gd
        --enable-gd \
        --with-freetype=/usr/include/ \
        --with-jpeg=/usr/include/ \
        --with-avif=/usr/include/ \
        --with-webp=/usr/include/ \
        --with-xpm=/usr/include/ \
    # PDO: Databases
        --with-pdo-pgsql=/usr/include/ \
        --with-pdo-mysql \
    # Misc
        --with-zip=/usr/include/ \
        --with-bz2=/usr/include/ \
        --with-openssl=/usr/include/ \
        --with-enchant=/usr/include/enchant \
        --with-mysqli \
        --with-curl=/usr/include/ \
        --with-zlib=/usr/include/ \
        --with-ffi=/usr/include/ \
        --with-sodium=/usr/include/ \
    # PHP-FPM
        --enable-fpm \
    # PHP-FPM: User
        --with-fpm-user=www-data \
        --with-fpm-group=www-data \
    # PHP-CGI and CLI
        --disable-cgi \
        --disable-cli \
    # Thread Safety
        --enable-zts \
    && make \
    && make test \
    && make install \
    && apk del build
    # ==============================================================================================================================
