#!/usr/bin/env bash

ROOT=$(realpath "$(dirname $(realpath $0))/..")

source $ROOT/scripts/util.sh

#############################################################################
# configuration

IMAGE="${image:-sangwo/workstation:latest}"
CONTAINER=${name:-workstation}
# todo check port is usable
PUBLISH_PORT="${publish_port:-127.0.0.0:8000-8002:8000-8002}"
# xdebug required
HOST_IP="${host_ip:-$(determine_local_ip || exit 1)}"
MEMORY_LIMIT=$(available_memory ${memory_percent:-0.8} || exit 1)
CPU_LIMIT=$(available_cpu ${cpu_percent:-0.8})

#############################################################################
# main

clean() {
    {
        docker stop $CONTAINER
        docker rm $CONTAINER
    } &>/dev/null

    return 0
}

run() {

    local option=(
    "$(printf -- '-v %s -v %s -v %s' \
        "$ROOT/var/haoliang:/home/haoliang" \
        "/srv/http:/srv/http" \
        "/srv/golang:/srv/golang")"
    "$(printf -- '-e XDEBUG_CONFIG="remote_host=%s"' \
        "$HOST_IP")"
    "$(printf -- '-p %s -m %s --cpus %s' \
        "$PUBLISH_PORT" \
        "$MEMORY_LIMIT" \
        "$CPU_LIMIT")"
    # see https://github.com/derekparker/delve/issues/515
    "--security-opt=seccomp:unconfined"
    "$(printf -- "-e HOST_IP=%s" \
        "$HOST_IP")"
    "-d -w /srv/http --net=hub"
    "--name ${CONTAINER} ${IMAGE}"
    )

    eval docker run "${option[@]}"
}

main() {

    clean

    echo "using image $IMAGE, and running container be named as $CONTAINER"

    if ! run; then
        echo "just can not start the $CONTAINER"
        return 1
    fi

    echo "everything is fine."
}

cd $ROOT && main
