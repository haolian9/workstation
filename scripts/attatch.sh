#!/usr/bin/env bash

CONTAINER=${container:-workstation}

if [ $( docker ps --filter="name=$CONTAINER" | wc -l ) -lt 2 ]; then
    echo "please start $CONTAINER"
    exit 1
fi

exec docker exec -it $CONTAINER zsh
