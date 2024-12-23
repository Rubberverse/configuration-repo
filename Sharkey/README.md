# Sharkey

Drop-in replacement for [activitypub.software/transfem-org/Sharkey](https://activitypub.software/TransFem-org/Sharkey) for manual build.

## Why?

Alpine Linux fails to resolve DNS names under NodeJS when deployed via Pod or via Kubernetes (unless CacheDNS is used) due to it's use of `musl`.

This Dockerfile changes the base image to something that works, albeit with a higher filesize - Debian.

## Changes

- Slightly modified the Dockerfile so it runs under `nodejs:20-bookworm-slim` image. Rest was left as-is so all credits go to Sharkey developers and contributors.
- `LD_PRELOAD` variable points to correct location of `libjemalloc2` on Debian image.

## Usage

Just took the Dockerfile and changed few things so it now runs under nodejs:bookworm-slim image,
LD_PRELOAD points to Debian location of libjemalloc2 and any extra dependency was taken care of.

1. Git clone stable branch of above repository
2. Replace Dockerfile with one here
3. Build
4. Profit
