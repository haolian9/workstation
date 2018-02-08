#!/usr/bin/env bash

WS_IMG="sangwo/workstation:${WS_IMG:=latest}"
WS_NAME=${WS_NAME:=workstation}
WS_PATH=$(dirname $(realpath $0))
# xdebug required
HOST_MACHINE_IP=$(ip addr show | grep 'inet\b'  | awk '{ print $2 }' | grep -v '^172\|127' | sed 's/\/.*$//')

{
    docker stop $WS_NAME
    docker rm $WS_NAME
} &>/dev/null

docker run -d \
    -v $WS_PATH/var/haoliang:/home/haoliang \
    -v $WS_PATH/var/root:/root \
    -v /srv/http:/srv/http \
    -v /srv/golang:/srv/golang \
    -w /srv/http \
    -e XDEBUG_CONFIG="remote_host=${HOST_MACHINE_IP}" \
    -e HOST_MACHINE_IP="${HOST_MACHINE_IP}" \
    --net=hub \
    --name $WS_NAME \
    $WS_IMG

