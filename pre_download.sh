#!/usr/bin/env sh

# why
#
# those stuffs usually under an unstable network connection in my local,

store_dir=$(dirname $0)/var/pre_download

# ref https://github.com/github/hub/releases
HUB_VERSION="2.2.9"
# ref https://github.com/simeji/jid/releases
JID_VERSION="0.7.2"
# ref https://github.com/etsy/phan/releases
PHAN_VERSION="0.8.3"

function download
{ #{{{

    curl -SL "https://getcomposer.org/composer.phar" \
        -o composer.phar

    curl -SsL "http://static.phpmd.org/php/latest/phpmd.phar" \
        -o phpmd.phar

    curl -SLO "https://github.com/simeji/jid/releases/download/$JID_VERSION/jid_linux_amd64.zip" \
        && 7z x jid_linux_amd64.zip && mv jid_linux_amd64 jid

    curl -L "https://github.com/etsy/phan/releases/download/$PHAN_VERSION/phan.phar" \
        -o phan.phar

    curl -SL "https://github.com/github/hub/releases/download/v$HUB_VERSION/hub-linux-amd64-$HUB_VERSION.tgz" \
        | tar xzf - && mv hub-linux-amd64-$HUB_VERSION hub

} #}}}

function clone
{ #{{{

    git clone https://aur.archlinux.org/package-query.git \
        package-query

    git clone https://aur.archlinux.org/yaourt.git \
        yaourt

    git clone https://github.com/facebook/PathPicker.git \
        pathpicker

    git clone https://github.com/paulirish/git-recent.git \
        git-recent

    git clone https://github.com/nikic/php-ast.git \
        php-ast

} #}}}

function main
{ #{{{

    if [ \( ! -d "$store_dir" \) -o \( ! -w "$store_dir" \) ]; then
        mkdir "$store_dir"
        if [ $? -ne 0 ]; then
            echo -n "$store_dir not exists or not writable. \n manually handle it before continue."
            return 1
        fi
    fi

    cd $store_dir

    download

    clone

} #}}}

main
