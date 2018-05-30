#!/usr/bin/env sh

CONTAINER=${container:-workstation}

if [ $( docker ps --filter="name=$CONTAINER" | wc -l ) -lt 2 ]; then
    echo "please start $CONTAINER"
    exit 1
fi

docker exec -it -u $(id -un) $CONTAINER /usr/bin/zsh
