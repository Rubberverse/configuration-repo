# Umami Analytics

Dockerfile that spins up and builds [umami-software/umami](https://github.com/umami-software/umami) in one go. Credits go to Umami developers and contributors, this Dockerfile is otherwise slightly modified to suit personal deployment needs (read more below)

All you need is to copy this Dockerfile somewhere and run `podman build -f Dockerfile -t localhost/umami:latest-postgresql --buildargs=GIT_REMOTE_TAG=vxx.xx.xx` against it.

Replace `GIT_REMOTE_TAG` with appropriate version tag from their repository.

## Changes

This Dockerfile is a modification of the base one that just changes it to:

1. Pull source repository into `source-code` layer
2. Build it with `nodejs:18-bookworm` instead

I've had issues deploying Alpine Linux variant of the official image thus I've opted for this approach as Debian NodeJS images have 0 issues with DNS resolving. If you get errors such as `ENOTFOUND` or something similar then consider building it manually from here!
