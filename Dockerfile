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
        && curl -SL "https://getcomposer.org/composer.phar" -o /usr/local/bin/composer \
        && chmod +x /usr/local/bin/composer

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

RUN pecl update-channels && pecl install channel://pecl.php.net/msgpack-2.0.2
COPY ./config/php/msgpack.ini /etc/php/conf.d/msgpack.ini

RUN yes | pacman -Syy \
        && yes | pacman -S --needed vifm

RUN pecl update-channels && pecl install ds

RUN git clone https://github.com/facebook/PathPicker.git /opt/pathpicker\
        && ln -s /opt/pathpicker/fpp /usr/local/bin/fpp

RUN yes | pacman -Syy \
        && yes | pacman -S --needed tree

# ext-mongodb
RUN yes | pacman -Syy \
        && yes | pacman -S --needed php-mongodb
COPY ./config/php/mongodb.ini /etc/php/conf.d/mongodb.ini

RUN yes | pacman -Syy \
        && yes | pacman -S --needed bc

# mongo shell
RUN yes | pacman -Syy \
        && yes | pacman -S --needed mongodb mongodb-tools

RUN yes | pacman -Syy \
        && yes | pacman -S --needed npm

RUN curl -SsL http://static.phpmd.org/php/latest/phpmd.phar -o /usr/local/bin/phpmd \
        && chmod +x /usr/local/bin/phpmd

RUN pip install tmuxp

VOLUME ["/root"]

RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

# php-ast
RUN git clone https://github.com/nikic/php-ast.git /tmp/php-ast \
    && cd /tmp/php-ast && phpize && ./configure && make && make install

RUN yes | pacman -S php-sqlite
#RUN curl -L https://github.com/etsy/phan/releases/download/0.6/phan.phar -o /usr/local/bin/phan \
#        && chmod +x /usr/local/bin/phan
#COPY ./config/php/ast.ini /etc/php/conf.d/ast.ini

RUN git clone https://github.com/paulirish/git-recent.git /opt/git-recent \
        && ln -s /opt/git-recent/git-recent /usr/local/bin/git-recent \
        && chmod +x /usr/local/bin/git-recent

RUN yes | pacman -Syy \
        && yes | pacman -S --needed task

RUN yes | pacman -Syy \
        && yes | pacman -S --needed php-pgsql

RUN yes | pacman -Syy \
        && yes | pacman -S --needed p7zip

RUN curl -SL 'https://github.com/simeji/jid/releases/download/0.6.1/jid_linux_amd64.zip' -o /tmp/jid.zip \
    && cd /tmp && 7z e jid.zip && mv jid_linux_amd64 /usr/local/bin/jid && chmod +x /usr/local/bin/jid

COPY ./config/php/ds.ini /etc/php/conf.d/ds.ini

# zookeeper
#RUN yaourt --noconfirm -Syu \
#        && yaourt -S --noconfirm zookeeper

RUN pecl channel-update pecl.php.net && pecl install channel://pecl.php.net/ssh2-1.0

RUN yes | pacman -Scc
RUN rm -rf /tmp/*

ENTRYPOINT ["docker-entrypoint.sh"]

