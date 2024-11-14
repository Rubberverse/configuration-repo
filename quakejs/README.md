## Credits

- [realies/quakejs-docker fork of treyyoder/quakejs-docker](https://github.com/realies/quakejs-docker) - Fork that adds nginx and allows to reverse proxy with https, modified here further.
- [treyyoder/quakejs-docker](https://github.com/treyyoder/quakejs-docker) - Dockerized variant
- [begleysm/quakejs](https://github.com/begleysm/quakejs) - Fixed and improved community version
- [inolen/quakejs](https://github.com/inolen/quakejs) - Original

## Changes

1. Chain multiple `RUN` statements instead
2. Run `nginx` and `quakejs` as quakejs user instead of making use of supervisor.d by chowning hardcoded nginx directories
3. Hacky way of bypassing NGINX's inability to serve static files via POST request

