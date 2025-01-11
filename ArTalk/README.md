## ArTalk

Drop-in replacement for [ArTalkJS/ArTalk](https://github.com/ArtalkJS/Artalk) for manual build. It is pretty useless though, you can achieve the same with my quadlet unit without need to rebuild. (MrRubberDucky/rubberverse.xyz)

As always, doesn't do much. Only updates `apk` packages so they're up-to-date, uses `alpine:edge` and runs as `artalk` user with UID and GID of `1001`

1. `git clone https://github.com/ArTalkJS/ArTalk.git`
2. Replace Dockerfile and docker-entrypoint.sh with versions from here
3. Build
4. Profit
