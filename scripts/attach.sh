#!/usr/bin/env bash

running_in_urxvt() {
    [ "$(ps -o comm= -p "$(($(ps -o ppid= -p "$(($(ps -o sid= -p "$$")))")))")" = "urxvt" ]
}

main() {

    is_container_running "$CONTAINER" || {
        >&2 echo "trying to start workstation daemon, using default settings"
        $ROOT/daemon.sh start || {
            >&2 echo "failed to start workstation daemon."
            return 1
        }
    }

    if [ $# -le 0 ]; then
        set -- zsh
    fi

    exec docker exec $INTERACTIVE_TTY $CONTAINER "$@"
}

#############################################################################
# definition

readonly ROOT=$(dirname $(realpath "$0"))
CONTAINER=${container:-workstation}

if [ -z "${INTERACTIVE_TTY+x}" ]; then
    INTERACTIVE_TTY="-it"
fi

source $ROOT/util.sh && main "$@"
