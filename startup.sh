#!/usr/bin/env bash

docker stop workstation
docker rm workstation

host_machine_ip=$(ip addr show | grep 'inet\b'  | awk '{ print $2 }' | grep -v '^172\|127' | sed 's/\/.*$//')

docker run -d \
    -v $(pwd)/var/haoliang:/home/haoliang \
    -v /srv/http:/srv/http \
    -v $(pwd):/docker \
    -w /srv/http \
    -e HOST_MACHINE_IP=$host_machine_ip \
    -p "9000:9000" \
    --net=hub \
    --name workstation \
    haoliang/workstation

