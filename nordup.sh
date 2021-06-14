#!/bin/bash
if [ -x /usr/bin/nordvpn ]; then
    nordvon c
    nordvpn killswitch enable
    if [ -d /home/nuc/docker/transmission/ ]; then
        cd /home/nuc/docker/transmission
        docker-compose up --no-recreate --detach
        cd /home/nuc/docker/jackett
        docker-compose up --no-recreate --detach
    fi
fi