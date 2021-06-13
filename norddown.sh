#!/bin/bash
if [ -x /usr/bin/nordvpn ]; then
nordvpn killswitch disable
nordvon d
fi
