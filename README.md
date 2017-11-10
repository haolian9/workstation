
# personal workstation


it based on docker, and include tools for my daily development workflow.

in use
----

* `$ ./startup.sh # run a container named workstation in daemon mode`
* `$ docker exec -it workspace zsh # attach to workspace container`

personal contents will locate in:
----

* /home/haoliang
* /root
* /srv/http

environment variables
---

* HOST_MACHINE_IP
    * `ssh "$USERNAME@$HOST_MACHINE_IP" notify-send 'hi from-docker-container'`

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

others
---

* In Dockerfile, I created a user named by my name, I have no idea to move it outside the Dockerfile
