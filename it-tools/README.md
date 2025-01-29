# IT-Tools

Replacement Dockerfile, entrypoint script and redis config for [CorantinTh/it-tools](https://github.com/CorentinTh/it-tools)

## Why?

Base image runs as `root` user and without some additional tweaks that are better to do during build, it can be quite annoying working around them. So, just a simple modification to add a rootless user, chown some nginx directories along with a modified `nginx.conf` to expose it at port `9003` instead.

## Changes

- Runs as `nginx_user`
- Changes ownership of directories to rootless container user to fix permission issues

## Building

1. `git clone https://github.com/CorentinTh/it-tools.git`
2. Replace `Dockerfile` and `nginx.cof` with ones from this repository
3. Build `podman build -f Dockerfile -t localhost/it-tools:latest`

## Example Quadlet deployment

```ini
# ~/.config/containers/systemd/IT-Tools.container
[Unit]
Description=it-tools

[Service]
Restart=on-failure

[Container]
Image=localhost/it-tools:latest
ContainerName=it-tools
User=1001:1001
UserNS=auto
NoNewPrivileges=true
Network=pasta:--ipv4-only
PublishPort=127.0.0.1:9002:9002

[Install]
WantedBy=default.target
```
