#!/bin/bash
# Copyright  Stefan Klinger <http://stefan-klinger.de>
set -u -e -C;
shopt -s nullglob;

exec watch -n1 -c "$@"
