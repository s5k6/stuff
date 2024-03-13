#!/bin/bash
# Copyright 2019 Stefan Klinger <http://stefan-klinger.de>
set -u -e -C;
shopt -s nullglob;

function err { echo $'\e[1;31m'"$@"$'\e[m' >&2; exit 1; }
function warn { echo $'\e[1;35m'"$@"$'\e[m' >&2; }
function info { echo $'\e[36m'"$@"$'\e[m'; }

dir="${HOME}/.tpl";

if test -z "${1:-}"; then
    ls -T0 --color=auto --si -l "$dir";
    err "Synopsis: tpl <what>? <newfile>";
fi;

if test "${2:-}"; then
    tpl="$1";
    name="$2";
else
    name="$1";
    tpl="${name##*.}";
    if test "$tpl" = "$name" -o -z "$tpl"; then
        tpl=DEFAULT;
    fi;
fi;

if test -e "${name}"; then
    err "File already exists: ${name}";
fi;

if ! test -e "${dir}/${tpl}"; then
    err "File not found: ${dir}/${tpl}";
fi;

cp -L "${dir}/${tpl}" "${name}";
e "${name}";
