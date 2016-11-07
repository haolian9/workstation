
# personal workstation


it based on docker, and include tools for my daily development workflow.

in use
----

* `$ ./startup.sh # this will run a container named workspace in daemon mode`
* `$ docker exec -it workspace /usr/bin/zsh # connect to workspace container, and run your magic commands`


why?
----

~~Mac OS is not suit for me. I currently using a macbook pro and can not choose it's OS.~~

Finally, I abandoned MBP. But I found that I can not leave docker.


what tools will it takes ?
----

* archlinux
* vim
* tmux
* mycli
* ag
* git
* composer
* shadowsocks
* proxychains-ng
* ...

personal contents will locate in:
----

* /root
* /srv/http

notes
----

* Developping within a docker container, I/O is really slow. ( but in my lenovo laptop mounted with a 5400/s hd, I actually can not feel it; It was occured at MBP I privous used. )
* I would rather add new `RUN` command than refactor the former `RUN` command; since image base on image layer, and each `RUN` will create a new image layer.

tips
----

* ssh "$USERNAME@$HOST_MACHINE_IP" notify-send 'hi from docker-container'

FAQ
----

* tmux erred: lost server
    * run `$ script` first, before using `tmux`
    * if you did not instantiate the image as daemon, but `docker run --it`, this issue won't occur.
* how to use xdebug
    * when you `$ ./startup.sh`:
        * startup.sh will
            * inject host machine ip to container an env named HOST_MACHINE_IP
            * bind container port 9000 to host machine port 29000
        * docker-entrypoint.sh will change xdebug.remote_host = $HOST_MACHINE_IP
* `no permission to read from` when build image
    * chown/mod ./var/root

