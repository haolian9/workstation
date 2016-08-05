FROM pritunl/archlinux

VOLUME ["/srv/http", "/root", "/tmp"]

WORKDIR /srv/http

COPY ./workspace-entrypoint.sh /usr/local/bin/workspace-entrypoint.sh

COPY ./config/mirrorlist /etc/pacman.d/mirrorlist

# pacman -S base
RUN yes | pacman -Syy \
        && yes | pacman -S --needed bash bzip2 coreutils cryptsetup device-mapper dhcpcd diffutils e2fsprogs file filesystem findutils gawk gcc-libs gettext glibc grep gzip inetutils iproute2 iputils jfsutils less licenses linux logrotate lvm2 man-db man-pages mdadm nano netctl pacman pciutils pcmciautils perl procps-ng psmisc reiserfsprogs s-nail sed shadow sysfsutils systemd-sysvcompat tar texinfo usbutils util-linux vi which xfsprogs

# pacman -S base-devel
RUN yes | pacman -Syy \
        && yes | pacman -S --needed autoconf automake binutils bison fakeroot file findutils flex gawk gcc gettext grep groff gzip libtool m4 make pacman patch pkg-config sed sudo texinfo util-linux which

# php
RUN yes | pacman -Syy \
        && yes | pacman -S --needed php php-gd php-intl php-mcrypt php-docs

# tool
RUN yes | pacman -Syy \
        && yes | pacman -S --needed vim neovim \
        && yes | pacman -S --needed python python-neovim python-pip \
        && yes | pacman -S --needed zsh grml-zsh-config tmux \
        && yes | pacman -S --needed git the_silver_searcher autojump fzf \
        && yes | pacman -S --needed openssh openssl

RUN pip install mycli

RUN yes | pacman -Syy \
        && yes | pacman -S --needed shadowsocks proxychains-ng

# xdebug
RUN yes | pacman -Syy \
        && yes | pacman -S --needed xdebug

# php config
COPY ./config/php/php.ini /etc/php/php.ini
COPY ./config/php/xdebug.ini /etc/php/conf.d/xdebug.ini

RUN yes | pacman -Syy \
        && yes | pacman -S --needed ruby

RUN gem install tmuxinator

RUN yes | pacman -Syy \
        && yes | pacman -S --needed lsof

RUN yes | pacman -Syy \
        && yes | pacman -S --needed jq

RUN yes | pacman -Syy \
        && yes | pacman -S --needed mariadb-clients

RUN pip install httpie

RUN yes | pacman -Scc

ENTRYPOINT ["workspace-entrypoint.sh"]

