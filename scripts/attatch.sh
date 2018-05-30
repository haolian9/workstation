#!/usr/bin/env bash

CONTAINER=${container:-workstation}

if [ $( docker ps --filter="name=$CONTAINER" | wc -l ) -lt 2 ]; then
    echo "please start $CONTAINER"
    exit 1
fi

# see https://github.com/moby/moby/issues/35407
termArgs="$(printf -- '-e COLUMNS=%d -e LINES=%d' "$(tput cols)" "$(tput lines)")"

exec docker exec -it $termArgs $CONTAINER /usr/bin/zsh
