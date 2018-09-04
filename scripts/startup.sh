#!/usr/bin/env bash

ROOT=$(realpath "$(dirname $(realpath $0))/..")

source $ROOT/scripts/util.sh

#############################################################################
# configuration

IMAGE="${image:-sangwo/workstation:latest}"
CONTAINER=${name:-workstation}
# todo check port is usable
PUBLISH_PORT="${publish_port:-8000:8000}"
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

    # volume
    "-v $ROOT/var/haoliang:/home/haoliang"
    # todo just mount `/srv` ?
    "-v /srv/http:/srv/http"
    "-v /srv/golang:/srv/golang"
    "-v /srv/playground:/srv/playground"
    "-v /srv/python:/srv/python"

    # resource limitation
    "-m $MEMORY_LIMIT"
    "--cpus $CPU_LIMIT"

    # see https://github.com/derekparker/delve/issues/515
    "--security-opt=seccomp:unconfined"

    # misc
    "-e HOST_IP=$HOST_IP"
    "-e XDEBUG_CONFIG='remote_host=$HOST_IP'" \
    "-p $PUBLISH_PORT"
    "--net=hub"
    "-d -w /srv/http"

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
