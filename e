#!/bin/sh

function runs { type "$1" >/dev/null; }

test "${DISPLAY}" && runs emacsclient && exec emacsclient -a '' -c -n "$@"
runs nano && exec nano "$@"
runs vim && exec vim "$@"
runs vi && exec vi "$@"
