#!/usr/bin/env sh

path=$(pwd)

echo $path
echo

docker run --rm -it \
    -v $path:/srv/http -w /srv/http \
    --volume $SSH_AUTH_SOCK:/ssh-auth.sock \
    --env SSH_AUTH_SOCK=/ssh-auth.sock \
    -u $(id -u):$(id -g) \
    haoliang/composer $(echo "$@")

