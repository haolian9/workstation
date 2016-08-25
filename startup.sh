#!/usr/bin/env bash

docker stop workstation
docker rm workstation

docker run -d \
    -v $(pwd)/var/haoliang:/home/haoliang \
    -v /srv/http:/srv/http \
    -v $(pwd):/docker \
    -w /srv/http \
    -p "9000:9000" \
    --net=hub \
    --name workstation \
    haoliang/workstation

