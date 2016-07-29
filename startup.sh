#!/usr/bin/env bash

docker commit  workspace haoliang/workspace

docker stop workspace
docker rm workspace

docker run -d \
    -v $(pwd)/root:/root \
    -v /srv/http:/srv/http \
    -w /srv/http \
    --network hub \
    --name workspace \
    --entrypoint "" \
    haoliang/workspace

