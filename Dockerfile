FROM archlinux/base:latest

ENV MY_USERNAME=haoliang
ENV MY_PASSWD=xx
ENV MY_PKGMAKE_OPT="-sirc --noconfirm --needed"
ENV PHP_EXT_MSGPACK_VERSION=2.0.2
ENV PHP_EXT_SSH_VERSION=1.0
env PHP_EXT_SWOOLE_VERSION=2.0.1

# ref https://github.com/github/hub/releases
ENV HUB_VERSION="2.2.9"
# ref https://github.com/simeji/jid/releases
ENV JID_VERSION="0.7.2"
# ref https://github.com/etsy/phan/releases
ENV PHAN_VERSION="0.8.3"
# ref https://github.com/phpstan/phpstan/releases
ENV PHPSTAN_VERSION="0.8.5"
# ref https://github.com/rgburke/grv/releases
ENV GRV_VERSION="0.1.1"

COPY ./docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
COPY ./config/mirrorlist /etc/pacman.d/mirrorlist

# {{{ 基本环境

# {{{ create a normal user
RUN pacman -Syy --noconfirm \
    && pacman -S --noconfirm --needed sudo
RUN echo '%wheel ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers
RUN useradd -m -u 1000 -g users -G wheel $MY_USERNAME
RUN yes $MY_PASSWD | passwd $MY_USERNAME
# }}}

# 本地化
RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
RUN echo "zh_CN.UTF-8 UTF-8" >> /etc/locale.gen && locale-gen

# pacman -S base
RUN pacman -Syy --noconfirm \
    && pacman -S --noconfirm --needed \
    bash bzip2 coreutils \
    diffutils file filesystem findutils gawk gcc-libs glibc \
    grep gzip inetutils iproute2 iputils less licenses man-db man-pages \
    pacman perl procps-ng psmisc \
    sed shadow sysfsutils tar \
    util-linux which

# pacman -S base-devel
RUN pacman -Syy --noconfirm \
    && pacman -S --noconfirm --needed \
    autoconf automake binutils findutils \
    gcc groff \
    gzip libtool m4 make patch sudo \
    pkg-config fakeroot

# git, curl
RUN pacman -Syy --noconfirm \
    && pacman -S --noconfirm --needed \
    git \
    curl

USER $MY_USERNAME
RUN gpg --recv-keys --keyserver hkp://pgp.mit.edu 1EB2638FF56C0C53
RUN cd /tmp && git clone --depth 1 https://aur.archlinux.org/cower-git.git cower \
    && cd cower && makepkg $(echo $MY_PKGMAKE_OPT)
USER root

# }}}

# {{{ php

RUN pacman -Syy --noconfirm && pacman -S --noconfirm --needed \
    php \
    xdebug \
    php-intl \
    php-pgsql \
    php-apcu \
    php-mongodb

USER $MY_USERNAME
RUN cd /tmp && cower -d php-pear \
    && cd php-pear && makepkg $(echo $MY_PKGMAKE_OPT)
USER root

RUN pecl update-channels && pecl install \
        swoole-$PHP_EXT_SWOOLE_VERSION \
        msgpack-$PHP_EXT_MSGPACK_VERSION \
        ds \
        ssh2-$PHP_EXT_SSH_VERSION

# tool
RUN curl -SL "https://getcomposer.org/composer.phar" -o /usr/local/bin/composer \
    && chmod +x /usr/local/bin/composer

RUN curl -SsL "http://static.phpmd.org/php/latest/phpmd.phar" -o /usr/local/bin/phpmd \
    && chmod +x /usr/local/bin/phpmd

RUN curl -L "https://github.com/etsy/phan/releases/download/$PHAN_VERSION/phan.phar" -o /usr/local/bin/phan \
    && chmod +x /usr/local/bin/phan

RUN curl -L "https://github.com/phpstan/phpstan/releases/download/$PHPSTAN_VERSION/phpstan.phar" -o /usr/local/bin/phpstan \
    && chmod +x /usr/local/bin/phpstan

# modules can not install by pecl

RUN cd /tmp && git clone --depth 1 https://github.com/nikic/php-ast.git php-ast \
    && cd php-ast && phpize && ./configure && make && make install

RUN cd /tmp && git clone --depth 1 https://github.com/laruence/yac.git php-yac \
    && cd php-yac && phpize && ./configure && make && make install

COPY ./config/php/php.ini /etc/php/php.ini
COPY ./config/php/ext/    /etc/php/conf.d/

# }}}

# {{{ tools

RUN pacman -Syy --noconfirm && pacman -S --noconfirm --needed \
    neovim \
    python \
    python-neovim \
    python-pip \
    zsh \
    grml-zsh-config \
    tmux \
    the_silver_searcher \
    autojump \
    fzf \
    openssh \
    openssl \
    lsof \
    jq \
    mariadb-clients \
    whois \
    vifm \
    tree \
    bc \
    p7zip \
    dos2unix \
    traceroute \
    bind-tools \
    tcpdump \
    sysstat \
    socat \
    shellcheck

USER $MY_USERNAME
RUN cd /tmp && cower -d universal-ctags-git \
    && cd universal-ctags-git && makepkg $(echo $MY_PKGMAKE_OPT)
RUN cd /tmp && cower -d gotty \
    && cd gotty && makepkg $(echo $MY_PKGMAKE_OPT)
USER root

# tools can not be installed by pacman

RUN git clone --depth 1 https://github.com/paulirish/git-recent.git /opt/git-recent \
    && ln -s /opt/git-recent/git-recent /usr/local/bin/git-recent && chmod +x /usr/local/bin/git-recent

RUN cd /tmp && curl -SLO "https://github.com/simeji/jid/releases/download/$JID_VERSION/jid_linux_amd64.zip" \
    && 7z x jid_linux_amd64.zip \
    && cp jid_linux_amd64 /usr/local/bin/jid && chmod +x /usr/local/bin/jid

RUN cd /tmp && curl -SL "https://github.com/github/hub/releases/download/v$HUB_VERSION/hub-linux-amd64-$HUB_VERSION.tgz" | tar xzf - \
    && hub-linux-amd64-$HUB_VERSION/install

RUN cd /tmp && curl -SL "https://github.com/rgburke/grv/releases/download/v${GRV_VERSION}/grv_v${GRV_VERSION}_linux64" -o /usr/local/bin/grv \
    && chmod +x /usr/local/bin/grv

RUN pip install mycli

# }}}

# go {{{
RUN pacman -Syy --noconfirm && pacman -S --noconfirm --needed \
    go go-tools \
    delve dep

USER $MY_USERNAME
RUN cd /tmp && cower -d gometalinter-git \
    && cd gometalinter-git && makepkg $(echo $MY_PKGMAKE_OPT)
USER root
# }}}

# {{{ 善后

RUN pacman -Syu --noconfirm

RUN pacman -Scc --noconfirm
RUN rm -rf /tmp/*

VOLUME ["/srv/http"]
VOLUME ["/root"]
VOLUME ["/home/$MY_USERNAME"]
VOLUME ["/srv/golang"]

RUN unset MY_USERNAME MY_PASSWD MY_PKGMAKE_OPT

WORKDIR /srv/http

ENTRYPOINT ["docker-entrypoint.sh"]

# }}}

# {{{ run as non-privileged user
USER $MY_USERNAME
# }}}
