## IT-Tools

Drop-in replacement for [CorentinTh/it-tools](https://github.com/CorentinTh/it-tools) for manual build.

Does nothing unusual, just made it run as a nginx_user with UID of 1001 and GID of 1001.

1. `git clone https://github.com/CorentinTh/it-tools.git`
2. Replace Dockerfile with one here
3. Edit nginx.conf port to point to anything but <1000
4. Build
5. Profit
