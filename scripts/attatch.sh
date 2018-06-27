#!/usr/bin/env bash

CONTAINER=${container:-workstation}

if [ $( docker ps --filter="name=$CONTAINER" | wc -l ) -lt 2 ]; then
    echo "please start $CONTAINER"
    exit 1
fi

# see https://github.com/moby/moby/issues/35407
# but did not work
#termArgs="$(printf -- '-e COLUMNS=%d -e LINES=%d' "$(tput cols)" "$(tput lines)")"

exec docker exec -it $CONTAINER zsh
