#!/usr/bin/env bash

docker build -t haoliang/workspace .

docker run --rm -it \
    -v $(pwd)/var/root:/root \
    -v /srv/http:/srv/http \
    -v $(pwd):/docker \
    -v $(pwd)/var/tmp:/tmp \
    -w /srv/http \
    --network hub \
    --name workspace \
    haoliang/workspace /bin/bash

# for -d, --entrypoint  workspace-entrypoint.sh \
