#!/usr/bin/env bash

ROOT=$(dirname $(realpath $0))

source $ROOT/scripts/util.sh

#############################################################################
# configuration

IMG="${image:-sangwo/workstation:latest}"
NAME=${name:-workstation}
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
        docker stop $NAME
        docker rm $NAME
    } &>/dev/null

    return 0
}

run() {
    docker run -d \
        -v $ROOT/var/haoliang:/home/haoliang \
        -v $ROOT/var/root:/root \
        -v /srv/http:/srv/http \
        -v /srv/golang:/srv/golang \
        -w /srv/http \
        -e XDEBUG_CONFIG="remote_host=${HOST_IP}" \
        -e HOST_IP="${HOST_IP}" \
        -p "${PUBLISH_PORT}" \
        -m "${MEMORY_LIMIT}" \
        --cpus "${CPU_LIMIT}" \
        --net=hub \
        --name $NAME \
        $IMG
}

main() {

    clean

    echo "using image $IMG, and running container be named as $NAME"

    if ! run; then
        echo "just can not start the $NAME"
        return 1
    fi

    echo "everything is fine."
}

cd $ROOT && main
