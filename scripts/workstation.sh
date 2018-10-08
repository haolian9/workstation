#!/usr/bin/env bash

logger() {
    local text="$*"

    [ -z "$text" ] && return

    text="[$(date '+%H:%M:%S')] $text"

    >&2 echo "$text"

    command -v notify-send &>/dev/null && notify-send "$(basename $0)" "$text"
}

print_usage() {
    cat <<'EOF'
SYNOPSIS
    <this> urxvt|session|attach|start|stop|restart [<args>...]

SUBCOMMANDS
    attach [<command>...]:    attatch to workstation container in the current terminal
    urxvt [<command>...]:     attach to workstation container in a standalone urxvt terminal with zsh shell
    session [<session-name>]: attach to workstation container in a standalone urxvt terminal with tmux session
    start|stop|restart:       start, stop or restart the workstation daemon
    help|h:                   show this help
EOF
}

main() {

    cd $ROOT || {
        logger "failed to cd in $ROOT (this script needs to store log/nohup.out in there)"
        return 1
    }

    case "$1" in
        urxvt|"")
            shift
            nohup urxvt -e $ROOT/attach.sh "$@" &
            logger "record nohup output to $(pwd)/nohup.out"
            ;;
        session)
            shift
            set -- /usr/local/bin/tmux_login_entry "$@"
            nohup urxvt -e $ROOT/attach.sh "$@" &
            logger "record nohup output to $(pwd)/nohup.out"
            ;;
        attach)
            shift
            exec $ROOT/attach.sh "$@"
            ;;
        start)
            exec $ROOT/daemon.sh start
            ;;
        stop)
            exec $ROOT/daemon.sh stop
            ;;
        restart)
            $ROOT/daemon.sh stop && $ROOT/daemon.sh start
            ;;
        help|h)
            print_usage
            ;;
        *)
            >&2 echo "unsupport operation"
            return 1
            ;;
    esac

}

readonly ROOT="$(dirname $(realpath "$0"))"

main "$@"
