## Sharkey

Drop-in replacement for [activitypub.software/transfem-org/Sharkey](https://activitypub.software/TransFem-org/Sharkey) for manual build.

Since Alpine Linux has skill issue with NodeJS DNS (under Pod deployment or Kubernetes) due to it's use of musl. `bind-tools` didn't really fix it in my experience. 

Just took the Dockerfile and changed few things so it now runs under nodejs:bookworm-slim image,
LD_PRELOAD points to Debian location of libjemalloc2 and any extra dependency was taken care of.

1. Git clone stable branch of above repository
2. Replace Dockerfile with one here
3. Build
4. Profit

(Still need to setup whole stack yourself, I'll have Quadlet files up for this soon.)
