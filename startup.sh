#!/usr/bin/env bash

determine_local_ip() {
    local ip_list=()
    local docker_spec='docker\|br-\|veth'

    for dev in $(ip link | grep '^[0-9]\+:' | awk '{ print $2 }' | grep -v lo | grep -v $docker_spec | tr -d : ); do
        local my_ip=""
        my_ip=$(ip addr show dev $dev | grep 'inet\b' | awk '{ print $2 }' | sed 's/[\/].*$//')
        if [ -z "$my_ip" ]; then
            continue;
        fi
        ip_list+=("$my_ip")
    done

    if [ "${#ip_list[@]}" -gt 1 ]; then
        >&2 echo "can not determine the ip, found: ${ip_list[*]}"
        return 1
    fi

    echo ${ip_list[0]}
}

available_memory() {
    local percent=${1:?requires percent arg}

    local total=$(lsmem -b -o SIZE | grep -i 'total online memory:' | grep '[0-9]\+' --only-matching)

    [ -z "$total" ] && {
        >&2 echo "invalid total memory, '$total'"
        return 1
    }

    printf "%.2fG" $(echo "$total / 1024/1024/1024 * $percent" | bc -l)
}

available_cpu() {
    local percent=${1:?requires percent arg}
    local total=$(nproc)

    printf "%.1f" $(echo "$total * $percent" | bc -l)
}

#############################################################################
# configuration

ROOT=$(dirname $(realpath $0))

IMG="sangwo/workstation:${tag:-latest}"
NAME=${name:-workstation}
# todo check port is usable
PUBLISH_PORT="${publish_port:-127.0.0.0:8000-8002:8000-8002}"
# xdebug required
HOST_IP="${host_ip:-$(determine_local_ip || exit 1)}"
MEMORY_LIMIT=$(available_memory ${memory_percent:-0.8} || exit 1)
CPU_LIMIT=$(available_cpu ${cpu_percent:-0.8})

#############################################################################
# main

{
    docker stop $NAME
    docker rm $NAME
} &>/dev/null

echo "using image $IMG, and running container be named as $NAME"

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

if [ $? -eq 0 ]; then
    echo "everything is fine."
else
    echo "just can not start the $NAME"
    exit 1
fi
