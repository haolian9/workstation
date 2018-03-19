#!/usr/bin/env bash

IMG="sangwo/workstation:${tag:-'latest'}"
NAME=${name:-"workstation"}

ROOT=$(dirname $(realpath $0))
# xdebug required
HOST_IP=$(ip addr show | grep 'inet\b'  | awk '{ print $2 }' | grep -v '^172\|127' | sed 's/\/.*$//')

{
    docker stop $NAME
    docker rm $NAME
} &>/dev/null

docker run -d \
    -v $ROOT/var/haoliang:/home/haoliang \
    -v $ROOT/var/root:/root \
    -v /srv/http:/srv/http \
    -v /srv/golang:/srv/golang \
    -w /srv/http \
    -e XDEBUG_CONFIG="remote_host=${HOST_IP}" \
    -e HOST_IP="${HOST_IP}" \
    --net=hub \
    --name $NAME \
    $IMG

