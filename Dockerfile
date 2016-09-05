FROM pritunl/archlinux:latest

VOLUME ["/srv/http"]

WORKDIR /srv/http

COPY ./docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

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

RUN echo '%wheel ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers
RUN useradd -m -u 1000 -g users -G wheel haoliang
RUN yes xx | passwd haoliang
VOLUME ["/home/haoliang"]

# yaourt
USER haoliang
RUN mkdir /tmp/yaourt
RUN cd /tmp/yaourt \
        && git clone https://aur.archlinux.org/package-query.git && cd package-query && yes | makepkg -si \
        && cd /tmp/yaourt && git clone https://aur.archlinux.org/yaourt.git && cd yaourt && yes | makepkg -si
RUN sudo rm -rf /tmp/yaourt
# pecl
RUN yes | yaourt -Syy \
        && yes | yaourt -S --needed php-pear
USER root

# swoole
RUN pecl channel-update pecl.php.net && pecl install swoole
COPY ./config/php/swoole.ini /etc/php/conf.d/swoole.ini

# composer
RUN cd /tmp \
&& php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
&& php -r "if (hash_file('SHA384', 'composer-setup.php') === 'e115a8dc7871f15d853148a7fbac7da27d6c0030b848d9b3dc09e2a0388afed865e6a3d6b3c0fad45c48e2b5fc1196ae') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" \
&& php composer-setup.php \
&& php -r "unlink('composer-setup.php');" \
&& mv composer.phar /usr/local/bin/composer

RUN echo "zh_CN.UTF-8 UTF-8" >> /etc/locale.gen && locale-gen

RUN yes | pacman -Syy \
        && yes | pacman -S --needed php-apcu
COPY ./config/php/apcu.ini /etc/php/conf.d/apcu.ini

RUN pip install mycli

# tag generator
RUN yes | pacman -Syy \
        && yes | pacman -S --needed ctags

RUN curl -Ss http://vim-php.com/phpctags/install/phpctags.phar > /usr/local/bin/phpctags \
        && chmod +x /usr/local/bin/phpctags

RUN yes | pacman -Syy \
        && yes | pacman -S --needed whois

RUN pecl update-channels && pecl install channel://pecl.php.net/msgpack-2.0.1
COPY ./config/php/msgpack.ini /etc/php/conf.d/msgpack.ini

RUN yes | pacman -Syy \
        && yes | pacman -S --needed vifm

RUN pecl update-channels && pecl install ds

RUN mkdir -p /opt \
        && git clone git@github.com:facebook/PathPicker.git pathpicker\
        ln -s /opt/pathpicker/fpp /usr/local/bin/fpp

RUN yes | pacman -Syy \
        && yes | pacman -S --needed tree

RUN yes | pacman -Scc
RUN rm -rf /tmp/*

ENTRYPOINT ["docker-entrypoint.sh"]

