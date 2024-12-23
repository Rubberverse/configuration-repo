# Umami Analytics

Dockerfile that spins up and builds [umami-software/umami](https://github.com/umami-software/umami) in one go. Credits go to Umami developers and contributors, this Dockerfile is otherwise slightly modified to suit personal deployment needs (read more below)

## Why?

Alpine Linux fails to resolve DNS names under NodeJS when deployed via Pod or via Kubernetes (unless CacheDNS is used) due to it's use of `musl`.

This Dockerfile changes the base image to something that works, albeit with a higher filesize - Debian.

## Changes

- Pulls umami source code via git and stores it in `source-code` layer
- Re-uses `source-code` layer for building steps
- Changed `nodejs:18-alpine` to `nodejs:18-bookworm-slim`
- Small fix for `husky` error during build

## Usage

All you need is to copy this Dockerfile somewhere and run `podman build -f Dockerfile -t localhost/umami:latest-postgresql --buildargs=GIT_REMOTE_TAG=vxx.xx.xx` against it.

Replace `GIT_REMOTE_TAG` with appropriate version tag from their repository.
