# Rubberverse Config Repo

This repository houses various workarounds and modified scripts or Dockerfiles to make images run as rootless user from the start, dropping `su-exec` or optionally going around the reverse proxies included in them.

## Why?

My deployment ideology is that if your container needs to use `gosu`, `su-exec` etc. in order to "run", you're doing it wrong. However, that's my own opinion! It gives people the comfort of not having to manually fix up permissions on their host to match those of their container user so some are willing to "overlook it" in order to achieve more or so the same result.

However because I'm a stubborn idiot, I have opted for the approach of 'if I really like your project, I will find a way.' so thus this was born I guess.

## Experimental notice

All Dockerfiles, modified scripts and anything else you use from here is not the intended way to use the project. It also may or may not suddenly work with later versions. You use anything here at your own risk!

## Can I use them, or submit PRs on your behalf?

Yes, it's public out there so people can use it. Even if it's just submitting Quadlet deployment template to your favorite project.
