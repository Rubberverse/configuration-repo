## What is this?

**Base Image**: `alpine:3.19.1`

**Build Args**: `ALPINE_VERSION` (Unused), `BRANCH_TAG` (PHP Version Tag), `ENCHANT_TAG` (Enchant Git Version Tag), `PKG_CONFIG_PATH` (Location of tools)

**Description**: Small exercise I did out of pure boredom, a Dockerfile that compiles PHP with following things

- AbiWord/enchant
- calendar
- mbstring
- sockets
- opcache
- bcmath
- intl
- soap
- session
- mysqlnd
- xml
- gd (freetype, jpeg, avif, webp, xpm)
- pdo-pgsql
- pdo-mysql
- --with=(zip, bz2, openssl, mysqli, curl, zlib, ffi, sodium)
- fpm (fpm-user=www-data, fpm-group=www-data)
- --disable-cgi --disable-cli
- --enable-zts

Does nothing more. Just builds PHP from source with some extra enabled things and modules.
