# Sharkey

Replacement Dockerfile for [activitypub.software/transfem-org/Sharkey](https://activitypub.software/TransFem-org/Sharkey)

Image has been changed to use node:bookworm-slim from Alpine in order to solve the DNS issue under Podman pods getting `EADDRNOTFOUND` node error.

## Why?

Alpine Linux fails to resolve DNS names under NodeJS when deployed via Pod or via Kubernetes (unless CacheDNS is used) due to it's use of `musl`.

This Dockerfile changes the base image to something that works, albeit with a higher filesize - Debian.

## Changes

- Base image changed from node:alpine to node:bookworm-slim
- `LD_PRELOAD` variable points to correct location of `libjemalloc2` on Debian image
- The rest of the Dockerfile is untouched

## Building

1. `git clone https://activitypub.software/TransFem-org/Sharkey.git -b stable`
2. Replace Dockerfile with one here
3. Build with `podman build -f Dockerfile -t localhost/sharkey:latest`

## Example Quadlet deployment

Pod deployment consists of Sharkey, PostgreSQL, Redis and Meilisearch

```ini
# ~/.config/containers/systemd/Sharkey/SHARKEY_WEB.container
[Unit]
Description=Sharkey Web Component
Requires=SHARKEY-PGSQL.service
Requires=SHARKEY-REDIS.service
Requires=SHARKEY-MEILI.service

[Service]
Restart=on-failure

[Install]
WantedBy=default.target

[Container]
Image=localhost/sharkey:latest
ContainerName=sharkey-web
Secret=PGSQL__SHARKEY_PW,type=env,target=POSTGRES_PASSWORD
Secret=PGSQL__SHARKEY_USER,type=env,target=POSTGRES_USER
Environment=MISSKEY_URL=<your domain>
Environment=POSTGRES_DB=<sharkey databaase name>
Environment=DATABASE_URL="postgres://sharkey-pgsql:5432/<sharkey database name>"
Mount=type=bind,src=/home/<your_user>/AppData/2_PERSIST/SHARKEY,dst=/sharkey/files,U=true,Z
Volume=${HOME}/AppData/1_CONFIGS/SHARKEY:/sharkey/.config:ro,Z,rbind,U
User=sharkey
UserNS=auto
Pod=SHARKEY.pod
```
```ini
# ~/.config/containers/systemd/Sharkey/SHARKEY-REDIS.container
[Unit]
Description=Sharkey Web Component
Requires=SHARKEY-PGSQL.service
Before=SHARKEY-WEB.service

[Service]
Restart=always

[Install]
WantedBy=default.target

[Container]
Image=docker.io/library/redis:7.4.0
Mount=type=bind,src=/home/<your_user>/AppData/4_DATABASES/SHARKEY_REDIS,dst=/data,U=true,Z
Volume=${HOME}/AppData/1_CONFIGS/REDIS.CONF:/usr/local/etc/redis/redis.conf:ro,U,Z
Environment=TZ=Europe/Warsaw
ContainerName=sharkey-redis
HealthCmd=redis-cli ping
HealthInterval=5s
HealthRetries=20
HealthTimeout=5s
Notify=healthy
Exec=redis-server /usr/local/etc/redis/redis.conf
User=redis
UserNS=auto
Pod=SHARKEY.pod
```
```ini
# ~/.config/containers/systemd/Sharkey/SHARKEY_PGSQL.container
[Unit]
Description=PostgreSQL for Sharkey
Requires=SHARKEY-REDIS.service
Before=SHARKEY-WEB.service
Before=SHARKEY-REDIS.service
Before=SHARKEY-MEILI.service

[Service]
Restart=on-failure

[Container]
Image=docker.io/bitnami/postgresql:latest
ContainerName=sharkey-pgsql
Mount=type=bind,src=/home/<your_user>/AppData/4_DATABASES/SHARKEY_PGSQL,dst=/bitnami/postgresql,U=true,Z
Secret=PGSQL__SHARKEY_PW,type=env,target=POSTGRESQL_PASSWORD
Secret=PGSQL__SHARKEY_USER,type=env,target=POSTGRESQL_USERNAME
Environment=POSTGRESQL_DATABASE=<sharkey database name>
Environment=POSTGRESQL_TIMEZONE=Europe/Warsaw
Environment=POSTGRESQL_LOG_TIMEZONE=Europe/Warsaw
Environment=POSTGRESQL_REPLICATION_USE_PASSFILE=false
HealthCmd=pg_isready -d <sharkey database name>
HealthInterval=5s
HealthRetries=5
HealthTimeout=5s
Notify=healthy
AutoUpdate=registry
NoNewPrivileges=true
UserNS=auto
Pod=SHARKEY.pod

[Install]
WantedBy=default-user.target
```
```ini
# ~/.config/containers/systemd/Sharkey/SHARKEY-MEILI.container
[Unit]
Description=Meilisearch
Requires=SHARKEY-REDIS.service
Before=SHARKEY-WEB.service

[Service]
Restart=on-failure

[Container]
Image=localhost/meilisearch:latest
ContainerName=sharkey-meilisearch
Secret=MEILI__MASTER_KEY,type=env,target=MEILI_MASTER_KEY
Environment=MEILI_NO_ANALYTICS=true
Environment=MEILI_ENV=production
Volume=${HOME}/AppData/2_PERSIST/MEILISEARCH:/meili_data:rw,rbind,U,Z
User=meilisearch
UserNS=auto
Pod=SHARKEY.pod
```
```ini
# ~/.config/containers/systemd/Sharkey/Sharkey.pod
[Pod]
Network=SHARKEY.network
PublishPort=127.0.0.1:3001:3001
```
```ini
# ~/.config/containers/systemd/Sharkey/SHARKEY.network
[Network]
Driver=bridge
DisableDNS=false
IPv6=false
IPAMDriver=host-local
NetworkName=sharkey
PodmanArgs=-o=vlan=20
PodmanArgs=-o=com.docker.network.bridge.name=sharkey
PodmanArgs=-o=isolate=true
Internal=false
```
