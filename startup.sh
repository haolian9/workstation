#!/usr/bin/env bash

IMG="sangwo/workstation:"${tag:-"latest"}
NAME=${name:-"workstation"}

ROOT=$(dirname $(realpath $0))
# xdebug required
HOST_IP=$(ip addr show | grep 'inet\b'  | awk '{ print $2 }' | grep -v '^172\|127' | sed 's/\/.*$//')

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
    --net=hub \
    --name $NAME \
    $IMG

if [ $? -eq 0 ]; then
    echo "everything is fine."
else
    echo "just can not start the $NAME"
    exit 1
fi
