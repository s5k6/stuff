#!/bin/bash
# Copyright 2019 Stefan Klinger <http://stefan-klinger.de>

if test -z "${1}"; then
    exec xterm;
else
    exec xterm -e "$@";
fi& # note the ampersand
