#!/bin/bash

if test -z "${1}"; then
    exec xterm;
else
    exec xterm -e "$@";
fi& # note the ampersand
