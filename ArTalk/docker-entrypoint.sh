#!/bin/sh
set -e

if [ "$1" != 'gen' ] && [ ! -e /data/artalk.yml ] && [ ! -e /data/artalk-go.yml ]; then
    if [ -e /conf.yml ]; then
        # Move original config to `/data/` for upgrade (<= v2.1.8)
        cp /conf.yml /data/artalk.yml
        # Not writing it to file, just printing to console here due to undefined POSIX shell functions that I'm lazy to see if they actually work or not
        printf "%b" "# [v2.1.9+ Updated]\n
        # The new version of the Artalk container recommends mounting\n
        # an entire folder instead of a single file to avoid some issues.\n
        \n
        # The original config file has been moved to the /data/ folder,
        # please unmount the config file volume from your container\n
        # and edit /data/artalk.yml for configuration."
        echo "[info][docker] Copy config file from /conf.yml to /data/artalk.yml for upgrade"
    else
        # Generate new config
        artalk gen conf /data/artalk.yml
        echo "[info][docker] Generate new config file to '/data/artalk.yml'"
    fi
fi

exec /usr/bin/artalk "$@"
