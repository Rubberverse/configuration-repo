# Homarr

Replacement Dockerfile, entrypoint script and redis config for [Homarr](https://github.com/homarr-labs/homarr)

Image has been changed to use Bullseye from Alpine in order to solve the DNS issue under Podman pods getting EADDRNOTFOUND thingamajig.

Opinionated, yeah.

## Changes

- Use node:bullseye-slim (Bookworm has Redis version that's too new apparently on APT repository)
- Run as rootless user by default
- Drop su-exec, gettext, nginx (Proxy it yourself)
- Redis config to listen to 127.0.0.1 specifically because defaults on Debian are weird (for some reason)
- Entrypoint script won't create the extra directories, nor Dockerfile.

## Building

1. `git clone https://github.com/homarr-labs/homarr.git -b v1.3.0`
2. Replace `Dockerfile`, `/packages/redis/redis.conf` and `/scripts/run.sh` with modified files here
3. Run build - `podman build -f Dockerfile -t localhost/homarr:v1.3.0`

## Example Quadlet deployment

```ini
# ~/.config/containers/systemd/Homarr/HOMARR.container
[Unit]
Description=Homarr Dashboard

[Service]
Restart=on-failure

[Container]
# Base
Image=localhost/homarr:v1.3.0
ContainerName=homarr
# Secrets
Secret=HOMARR_ENCRYPT_KEY,type=env,target=SECRET_ENCRYPTION_KEY
# Volumes - Main
Volume=${HOME}/AppData/2_PERSIST/HOMARR/DATABASE:/appdata/db:U,Z
Volume=${HOME}/AppData/2_PERSIST/HOMARR/REDIS:/appdata/redis:U,Z
Volume=${HOME}/AppData/2_PERSIST/HOMARR/CA:/appdata/trusted-certificates:U,Z
# User
User=1001:1001
UserNS=auto
Pod=Homarr.pod
# Labels
AutoUpdate=registry
NoNewPrivileges=true

[Install]
WantedBy=default.target
```
```ini
# ~/.config/containers/systemd/Homarr/Homarr.pod
[Pod]
Network=pasta:--ipv4-only
PublishPort=127.0.0.1:9105:3000
PublishPort=127.0.0.1:9106:3001
```

