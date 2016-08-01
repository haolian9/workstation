#!/usr/bin/env bash

docker build -t haoliang/workspace .

docker rm workspace

docker run -d \
    -v $(pwd)/var/root:/root \
    -v /srv/http:/srv/http \
    -v $(pwd):/docker \
    -v $(pwd)/var/tmp:/tmp \
    -w /srv/http \
    --network hub \
    --name workspace \
    haoliang/workspace


