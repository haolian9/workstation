#!/usr/bin/env bash

CONTAINER=${container:-workstation}

main() {
    {
        docker stop $CONTAINER
        docker rm $CONTAINER
    } &>/dev/null

    return 0
}

main
