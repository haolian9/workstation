#!/usr/bin/env bash

ROOT=$(dirname $(realpath "$0"))

source $ROOT/util.sh

CONTAINER=${container:-workstation}

is_container_running "$CONTAINER" || {
    >&2 echo "trying to start workstation daemon, using default settings"
    $ROOT/daemon.sh start || {
        >&2 echo "failed to start workstation daemon."
        exit 1
    }
}

exec docker exec -it $CONTAINER zsh
