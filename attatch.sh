#!/usr/bin/env sh

if [ $( docker ps --filter="name=workstation" | wc -l ) -lt 2 ]; then
    echo "please start workstation"
    exit 1
fi

docker exec -it -u $(id -un) workstation /usr/bin/zsh
