#!/bin/bash
if [ -x /usr/bin/nordvpn ]; then
#    if [ -d /home/nuc/docker/transmission/ ]; then
#        cd /home/nuc/docker/transmission
#        docker-compose down
#        cd /home/nuc/docker/jackett
#        docker-compose down
#    fi
nordvpn set killswitch disable
nordvpn d
fi
