#!/usr/bin/env bash

docker stop workstation
docker rm workstation

host_machine_ip=$(ip addr show | grep 'inet\b'  | awk '{ print $2 }' | grep -v '^172\|127' | sed 's/\/.*$//')

workstation_path=$(dirname $(realpath $0))

docker run -d \
    -v $workstation_path/var/haoliang:/home/haoliang \
    -v $workstation_path/var/root:/root \
    -v /srv/http:/srv/http \
    -v $workstation_path:/docker \
    -w /srv/http \
    -e HOST_MACHINE_IP=$host_machine_ip \
    -p "127.0.0.1:29000:9000" \
    --net=hub \
    --name workstation \
    haoliang/workstation

