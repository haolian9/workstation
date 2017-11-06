#!/usr/bin/env bash

sed -i "s/remote_host.\+$/remote_host = ${HOST_MACHINE_IP}/" /etc/php/conf.d/xdebug.ini

tail -f /dev/null
