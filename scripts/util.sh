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
