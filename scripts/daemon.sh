#!/usr/bin/env bash

#############################################################################
# func

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
    "-v $PROJECT_ROOT/var/haoliang:/home/haoliang"
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

    case "$1" in
        run|start|"")
            if is_container_existed "$CONTAINER"; then
                if is_container_running "$CONTAINER"; then
                    logger "$CONTAINER was running already"
                    return 0
                else
                    clean
                fi
            fi
            logger "using image $IMAGE, and running container with name $CONTAINER"
            if run; then
                logger "succeeded to start $CONTAINER"
            else
                logger "failed to start $CONTAINER"
                return 1
            fi
            ;;
        stop|down)
            logger "cleaning container instance"
            clean
            ;;
    esac

}

#############################################################################
# configuration

readonly ROOT=$(dirname $(realpath $0))
readonly PROJECT_ROOT=$(realpath "$ROOT/..")

source $ROOT/util.sh || exit 1

IMAGE="${image:-sangwo/workstation:latest}"
CONTAINER=${name:-workstation}

# todo check port is usable
PUBLISH_PORT="${publish_port:-127.0.0.1:8000:8000}"
# xdebug required
HOST_IP="${host_ip:-$(determine_local_ip || exit 1)}"
MEMORY_LIMIT=$(available_memory ${memory_percent:-0.8} || exit 1)
CPU_LIMIT=$(available_cpu ${cpu_percent:-0.8})

 cd $PROJECT_ROOT && main "$@"
