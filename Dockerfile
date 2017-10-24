#
# todo
# * php-pear install from aur
#

FROM pritunl/archlinux:latest

ENV MY_USERNAME=haoliang
ENV MY_PASSWD=xx
ENV PHP_EXT_MSGPACK_VERSION=2.0.2
ENV PHP_EXT_SSH_VERSION=1.0

COPY ./var/pre_download /tmp/
COPY ./docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
COPY ./config/mirrorlist /etc/pacman.d/mirrorlist

# {{{ 基本环境

# {{{ create a normal user
RUN echo '%wheel ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers
RUN useradd -m -u 1000 -g users -G wheel $MY_USERNAME
RUN yes $MY_PASSWD | passwd $MY_USERNAME
# }}}

# 本地化
RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
RUN echo "zh_CN.UTF-8 UTF-8" >> /etc/locale.gen && locale-gen

# pacman -S base
RUN pacman -Syy --noconfirm \
        && pacman -S --noconfirm --needed bash bzip2 coreutils cryptsetup device-mapper dhcpcd diffutils e2fsprogs file filesystem findutils gawk gcc-libs gettext glibc grep gzip inetutils iproute2 iputils jfsutils less licenses linux logrotate lvm2 man-db man-pages mdadm nano netctl pacman pciutils pcmciautils perl procps-ng psmisc reiserfsprogs s-nail sed shadow sysfsutils systemd-sysvcompat tar texinfo usbutils util-linux vi which xfsprogs

# pacman -S base-devel
RUN pacman -Syy --noconfirm \
        && pacman -S --noconfirm --needed autoconf automake binutils bison fakeroot file findutils flex gawk gcc gettext grep groff gzip libtool m4 make pacman patch pkg-config sed sudo texinfo util-linux which

RUN chown $MY_USERNAME:root /tmp/{package-query,yaourt}
USER $MY_USERNAME
RUN cd /tmp/package-query && makepkg -si --noconfirm \
        && cd /tmp/yaourt && makepkg -si --noconfirm
USER root

# }}}

# {{{ php

RUN pacman -Syy --noconfirm && pacman -S --noconfirm --needed \
        php \
        php-gd \
        php-intl \
        php-mcrypt \
        php-docs \
        xdebug \
        php-pgsql \
        php-apcu \
        php-sqlite \
        php-mongodb


RUN chown $MY_USERNAME:root /tmp/php-pear
USER $MY_USERNAME
RUN cd /tmp/php-pear && makepkg -si --noconfirm
USER root

RUN pecl update-channels && pecl install \
        swoole \
        channel://pecl.php.net/msgpack-$PHP_EXT_MSGPACK_VERSION \
        ds \
        channel://pecl.php.net/ssh2-$PHP_EXT_SSH_VERSION

# tool
RUN cp /tmp/composer.phar /usr/local/bin/composer && chmod +x /usr/local/bin/composer
RUN cp /tmp/phpmd.phar /usr/local/bin/phpmd && chmod +x /usr/local/bin/phpmd
RUN cp /tmp/phan.phar /usr/local/bin/phan && chmod +x /usr/local/bin/phan

# modules can not install by pecl
RUN cd /tmp/php-ast && phpize && ./configure && make && make install
RUN cd /tmp/php-yac && phpize && ./configure && make && make install

COPY ./config/php/php.ini /etc/php/php.ini
COPY ./config/php/ext/    /etc/php/conf.d/

# }}}

# {{{ tools

RUN pacman -Syy --noconfirm && pacman -S --noconfirm --needed \
        vim \
        neovim \
        python \
        python-neovim \
        python-pip \
        zsh \
        grml-zsh-config \
        tmux \
        git \
        the_silver_searcher \
        autojump \
        fzf \
        openssh \
        openssl \
        shadowsocks \
        proxychains-ng \
        lsof \
        jq \
        mariadb-clients \
        whois \
        vifm \
        tree \
        bc \
        mongodb mongodb-tools \
        npm \
        p7zip \
        dos2unix

USER $MY_USERNAME
RUN yaourt -Syy --noconfirm && yaourt -S --noconfirm --needed \
        universal-ctags-git
USER root

RUN cp -r /tmp/pathpicker /opt/pathpicker \
        && ln -s /opt/pathpicker/fpp /usr/local/bin/fpp \
        && chmod +x /usr/local/bin/fpp

RUN cp -r /tmp/git-recent /opt/git-recent \
        && ln -s /opt/git-recent/git-recent /usr/local/bin/git-recent \
        && chmod +x /usr/local/bin/git-recent

RUN cp -r /tmp/jid /usr/local/bin/jid \
    && chmod +x /usr/local/bin/jid

RUN /tmp/hub/install

RUN pip install mycli

# }}}

# {{{ 善后

RUN pacman -Syu --noconfirm

RUN pacman -Scc --noconfirm
RUN rm -rf /tmp/*

VOLUME ["/srv/http"]
VOLUME ["/root"]
VOLUME ["/home/$MY_USERNAME"]

WORKDIR /srv/http

ENTRYPOINT ["docker-entrypoint.sh"]

# }}}

