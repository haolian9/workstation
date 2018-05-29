#!/usr/bin/env bash

readonly make_flag="${make_flag:--sirc --noconfirm --needed}"

main() {

    [ $(id -u) -ne 0 ] || {
        >&2 echo "should run this script as non-privileged user, not root."
        return 1
    }

    cd /tmp || {
        >&2 echo "can not cd /tmp"
        return 1
    }

    [ $# -lt 1 ] && {
        >&2 echo "requires package args"
        return 1
    }

    for package; do
        make_install $package || {
            >&2 echo "install package ${package} failed."
            return 1
        }
    done
}

make_install() {

    local package="${1:?requires package name}"

    [ -d "$package" ] && {
        >&2 echo "dir '$package' already exists, might the package '$package' already be installed ?"
        return 1
    }

    echo "downloading package '$package'"
    cower -d $package || {
        >&2 echo "can not download the package ${package}"
        return 1
    }

    cd $package || {
        >&2 echo "could not cd $package which be considered same with the package name"
        return 1
    }

    echo "installing package '$package'"
    eval makepkg $make_flag
}

main "$@"
