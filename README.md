# Rubberverse Dockerfile(s)

Mish-mash of Dockerfile(s): for-fun, experimental and sometimes modified project Dockerfile(s) to suit my deployment needs.

## But why?

I have a specific ideology when deploying anything locally. It has to run rootlessly or at least give such option without crashing on startup with cursed errors or uselessly running `gosu` etc.

I yoink a project's Dockerfile and modify it to suit my needs then build the project locally instead. If something doesn't work, I try to find out why and modify the Dockerfile enough so it actually manages to run as a rootless user without any need of privileged actions.

If there's been significant modifications, project gets forked into sub-project outside of `various-dockerfiles` repository and maintained there ex. `qor-nginx`

## Can I use them?

I mean, yeah. It's public for a reason, go wild with it.

## Why not create a pull request?

I'm lazy and it also means going through reviews and whatever. If you think a change would benefit a project, steal it off here and contribute it to such project instead!

## Burger?

Borgar.
