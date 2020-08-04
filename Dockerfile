FROM sangwo/archlinux:latest

ENV MY_USERNAME=haoliang

COPY ./docker/scripts/ /usr/local/bin

# go #{{{
RUN pacman -Sy --noconfirm && pacman -S --noconfirm --needed \
    go go-tools \
    delve dep

USER $MY_USERNAME
RUN cower_install.sh golangci-lint-bin
USER root
# #}}}

# python #{{{
RUN pacman -Sy --noconfirm && pacman -S --noconfirm --needed \
    python python-docs \
    python-pip python-wheel \
    python-pylint flake8 mypy \
    ipython \
    poetry
# #}}}

# #{{{ tools

# essential
RUN pacman -Sy --noconfirm && pacman -S --noconfirm --needed \
    traceroute \
    bind-tools \
    tcpdump \
    sysstat \
    socat \
    strace \
    inotify-tools \
    netcat \
    openssh \
    openssl \
    lsof \
    whois \
    mosh \
    time \
    colordiff

# flow
RUN pacman -Sy --noconfirm && pacman -S --noconfirm --needed \
    neovim python-neovim \
    zsh grml-zsh-config \
    tmux \
    the_silver_searcher \
    fzf \
    shellcheck ctags \
    jq \
    vifm \
    stow \
    z

# standalone
RUN pacman -Sy --noconfirm && pacman -S --noconfirm --needed \
    mariadb-clients \
    tree \
    bc \
    p7zip \
    dos2unix \
    proxychains-ng \
    ansible ansible-lint

USER $MY_USERNAME
RUN cower_install.sh gotty
RUN cower_install.sh fpp-git
USER root

# #}}}

# #{{{ 善后

RUN pacman -Syu --noconfirm

RUN pacman -Scc --noconfirm
RUN rm -rf /tmp/*

# fixme
# see https://github.com/moby/moby/issues/3465#issuecomment-356988520
#unset MY_USERNAME

VOLUME ["/srv/http"]
VOLUME ["/root"]
VOLUME ["/home/$MY_USERNAME"]
VOLUME ["/srv/golang"]

WORKDIR /srv/http
USER $MY_USERNAME
ENTRYPOINT ["docker_entrypoint"]

# #}}}
