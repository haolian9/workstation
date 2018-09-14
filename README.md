what
---

{tools, env} for {php, go, shell} development

why
---

每次配置开发环境、同步修改非常麻烦，特别是有多台机子或云主机的时候.

特别设定
---

linux distro: archlinux

volume:
* ./var
* /srv/{http,golang}

default user: uid=1000

env:
* XDEBUG_CONFIG
* HOST_IP

resource limit:
* cpu 80%
* memory 80%

network: hub

scripts
---

脚本做了好多个性化的设定，你可能不想直接使用它

* daemon.sh 绑定了一些设置, 方便控制公开端口、限制内存、处理器的使用
* attatch.sh 方便进入运行中的容器
* build.sh 绑定了proxy设置
* makefile 上面这三个不太好记，放在makefile里, 方便调用
* 由于 make 必须在 makefile 的目录内执行，增加了 workstation.sh 来提供同等的功能


FAQ
----

* how to use xdebug
    * xdebug reads environment variable called `XDEBUG_CONFIG` and overwrite the config file configurations
    * but [few option](https://xdebug.org/docs/remote) can use:
        * idekey (in my tests, this not works)
        * remote_host
        * remote_port
        * remote_mode
        * remote_handler
* `no permission to read from` when build image
    * chown/mod ./var/root
* `ctrl-p twice`
    * https://stackoverflow.com/questions/20828657/docker-change-ctrlp-to-something-else

未解之谜
---

* In Dockerfile, I created a user named by my name, I have no idea to move it outside the Dockerfile

维护之痛
---

### 本地构建时, 网络简直是把杀猪刀

方法一: 不在本地构建

    * 在 play-with-docker.com 测试脚本成功后，触发 hub.docker.com 构建镜像，再拉取镜像。
    * hub.docker.com 交互体验给我的感觉很不好
    * play-with-docker.com 如果构建比较大的镜像会出现 磁盘空间不足的情况
    * 拉取镜像时， 可以使用 docker-cn.com 加速

方法二: 本地 + proxy + 国内源

    * http(s)?_proxy
        * 构建时 --build-arg
        * docker daemon 的配置文件
    * linux 的软件源
        * archlinux /etc/pacman.d/mirrorlist
        * debian 系 /etc/apt/sources.list
    * docker image mirror
        * docker-cn.com

### aur 经常出错，事情比较零碎，也很耗费时间

方法： 自己动手，丰衣足食
