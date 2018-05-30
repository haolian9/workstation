#!/usr/bin/env bash

ROOT=$(realpath "$(dirname $(realpath $0))/..")

source $ROOT/scripts/util.sh

#############################################################################
# definition

PROXY_ADDR="${proxy_addr:-$(determine_local_ip):8118}"
IMAGE="${image:-workstation}"

HTTP_PROXY="http://${PROXY_ADDR}"
HTTPS_PROXY="https://${PROXY_ADDR}"

#############################################################################

build() {
    docker build \
        --build-arg "HTTP_PROXY=$HTTP_PROXY HTTPS_PROXY=$HTTPS_PROXY" \
        -t "${IMAGE}" .

}

main() {
    if ! build; then
        >&2 echo "build failed"
        return 1
    fi

    echo "everything is fine"
}

cd $ROOT && main
