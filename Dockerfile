FROM archlinux/base:latest

ENV MY_USERNAME=haoliang
ENV MY_PASSWD=xx
ENV MY_PKGMAKE_OPT="-sirc --noconfirm --needed"

# ref https://github.com/etsy/phan/releases
ENV PHAN_VERSION="0.12.10"
# ref https://github.com/phpstan/phpstan/releases
ENV PHPSTAN_VERSION="0.9.2"
ENV YAC_VERSION="2.0.2"
ENV SWOOLE_VERSION="4.0.1"

COPY ./docker/scripts/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
COPY ./docker/config/mirrorlist /etc/pacman.d/mirrorlist

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
RUN cd /tmp && git clone --depth 1 https://aur.archlinux.org/cower-git.git cower \
    && cd cower && makepkg $(echo $MY_PKGMAKE_OPT)
COPY ./docker/scripts/cower_install.sh /usr/local/bin/cower_install.sh
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
# todo customize config of swoole
RUN cower_install.sh php-swoole \
    php-msgpack \
    php-ds-git \
    php-ssh-git \
    php-ast
USER root

# tool
RUN curl -SL "https://getcomposer.org/composer.phar" -o /usr/local/bin/composer \
    && chmod +x /usr/local/bin/composer

RUN curl -SsL "http://static.phpmd.org/php/latest/phpmd.phar" -o /usr/local/bin/phpmd \
    && chmod +x /usr/local/bin/phpmd

RUN curl -L "https://github.com/etsy/phan/releases/download/$PHAN_VERSION/phan.phar" -o /usr/local/bin/phan \
    && chmod +x /usr/local/bin/phan

RUN curl -L "https://github.com/phpstan/phpstan/releases/download/$PHPSTAN_VERSION/phpstan.phar" -o /usr/local/bin/phpstan \
    && chmod +x /usr/local/bin/phpstan

# ext
RUN cd /tmp && git clone -b "yac-${YAC_VERSION}" --single-branch --depth 1 "https://github.com/laruence/yac.git" \
    && cd yac && phpize && ./configure && make && make install

RUN cd /tmp && git clone -b "v${SWOOLE_VERSION}" --single-branch --depth 1 "https://github.com/swoole/swoole-src.git" \
    && cd swoole-src && git submodule update \
    && phpize && ./configure --enable-sockets --enable-openssl --enable-http2 --enable-async-hiredis \
    && make && make install

COPY ./docker/config/php/php.ini /etc/php/php.ini
COPY ./docker/config/php/ext/    /etc/php/conf.d/

# }}}

# go {{{
RUN pacman -Syy --noconfirm && pacman -S --noconfirm --needed \
    go go-tools \
    delve dep

USER $MY_USERNAME
RUN cower_install.sh gometalinter-git
USER root
# }}}

# {{{ tools

RUN pacman -Syy --noconfirm && pacman -S --noconfirm --needed \
    neovim \
    python \
    python-neovim \
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
    shellcheck \
    strace

USER $MY_USERNAME
RUN cower_install.sh universal-ctags-git \
    gotty \
    jid-bin \
    git-recent-git
USER root

# }}}

# {{{ 善后

RUN pacman -Syu --noconfirm

RUN pacman -Scc --noconfirm
RUN rm -rf /tmp/*

# fixme
# see https://github.com/moby/moby/issues/3465#issuecomment-356988520
#unset MY_USERNAME MY_PASSWD MY_PKGMAKE_OPT

VOLUME ["/srv/http"]
VOLUME ["/root"]
VOLUME ["/home/$MY_USERNAME"]
VOLUME ["/srv/golang"]

WORKDIR /srv/http
USER $MY_USERNAME
ENTRYPOINT ["docker-entrypoint.sh"]

# }}}
