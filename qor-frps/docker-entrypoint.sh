#!/bin/sh

# Colors
cend='\033[0m'
darkorange='\033[38;5;208m'
pink='\033[38;5;197m'
purple='\033[38;5;135m'
green='\033[38;5;41m'
blue='\033[38;5;99m'

case "$(echo "$DEPLOYMENT_TYPE" | tr '[:upper:]' '[:lower:]')" in
    client) export VAR_TYPE=1 ;;
    server) export VAR_TYPE=2 ;;
    *) export VAR_TYPE=ERR  ;;
esac


if test $VAR_TYPE != ERR; then
    printf "%b" "[✨ " "$purple" "Startup" "$cend" "] ✅ Your environmental variables are valid\n"
else
    printf "%b" "[❌ " "$pink" "Error" "$cend" "] Your DEPLOYMENT_TYPE environmental variable is invalid!\n"
    printf "%b" "Only " "$green" "valid" "$cend" " types are client or server (case insensitive)\n"
    printf "Confused? Read our Documentation! https://github.com/rubberverse\n"
    exit 1
fi

printf "%b" "$darkorange" " ______        _     _                                             \n(_____ \      | |   | |                                            \n _____) )_   _| |__ | |__  _____  ____ _   _ _____  ____ ___ _____ \n|  __  /| | | |  _ \|  _ \| ___ |/ ___) | | | ___ |/ ___)___) ___ |\n| |  \ \| |_| | |_) ) |_) ) ____| |    \ V /| ____| |  |___ | ____|\n|_|   |_|____/|____/|____/|_____)_|     \_/ |_____)_|  (___/|_____)\n" "$cend";
printf "=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-\n"
printf "%b" "🗒️ " "$blue" "Documentation" "$cend" " - https://github.com/rubberverse/frp/README.md\n"
printf "Hey who flicked the light switch off?\n"

if test $VAR_TYPE = 1 ; then
    printf "%b" "[✨" " $green" "Pre-Launch" "$cend" "] Launching frpc - fast reverse proxy client\n"
    exec /usr/bin/frpc -c /etc/frpc.toml
elif test $VAR_TYPE = 2; then
    printf "%b" "[✨" " $green" "Pre-Launch" "$cend" "] Launching frps - fast reverse proxy server\n"
    exec /usr/bin/frps -c /etc/frps.toml
else
    echo "Image error, tell maintainer to fix this"
    exit 2
fi
