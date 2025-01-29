## muse

All-In-One Dockerfile for building and serving [museofficial/muse](https://github.com/museofficial/muse), a music streaming Discord bot.

No need to pull source as this Dockerfile will automatically use `git clone` to grab it. Renders a big filesize for the container though, unfortunately (~1GB)

Runs rootless by default. Uses Debian `bookworm-slim` image as `alpine` ffmpeg builds have sound-stuttering issues from my experience.
