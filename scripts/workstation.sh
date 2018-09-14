#!/usr/bin/env bash

readonly ROOT="$(dirname $(realpath "$0"))"

case "$1" in
    attatch|"")
        $ROOT/attatch.sh
        ;;
    start)
        $ROOT/daemon.sh start
        ;;
    stop)
        $ROOT/daemon.sh stop
        ;;
    *)
        >&2 echo "unsupport operation"
        exit 1
        ;;
esac
