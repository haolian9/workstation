#!/usr/bin/env bash

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

#############################################################################
# definition

readonly ROOT="$(dirname $(realpath $0))"
readonly PROJECT_ROOT=$(realpath "$ROOT/..")

source $ROOT/util.sh || exit 1

PROXY_ADDR="${proxy_addr:-$(determine_local_ip):8118}"
IMAGE="${image:-workstation}"

HTTP_PROXY="http://${PROXY_ADDR}"
HTTPS_PROXY="https://${PROXY_ADDR}"

 cd $PROJECT_ROOT && main
