#!/bin/sh
# Copyright 2019 Stefan Klinger <http://stefan-klinger.de>

function avail { type "$1" >/dev/null; }

function debug {
    printf '\e[1m$'; printf ' %q' "$@"; printf '\e[m\n';
    #exec "$@";
    exit 1
}

# this is known to only work on bash
function isint { test "${1}" -eq "${1}" 2>/dev/null; }

if test "${DISPLAY}" && avail emacsclient; then

    list=()   # arguments passed to the call of emacsclient

    args=( "$@" )
    IFS=:  # used for read (1) and for recombination (2)


    for (( i = 0; i < "${#args[@]}"; i++ )); do
        a="${args[$i]}"
        if test "${a:0:1}" = '-' ; then
            list+=( "${a}" )
        elif test "${a:0:1}" = '+' ; then
            list+=( "${a}" )
        else

            # drop trailing `:`
            a="${a%:}"

            read -ra tokens <<<"${a}"               # (1)

            if isint "${tokens[-1]}"; then
                y="${tokens[-1]}"
                if isint "${tokens[-2]}"; then
                    x="${tokens[-2]}"
                    list+=( "+${x}:${y}" "${tokens[*]:0:${#tokens[@]}-2}" )
                else
                    list+=( "+${y}" "${tokens[*]:0:${#tokens[@]}-1}" )
                fi
            else
                list+=( "${tokens[*]}" )           # (2)
            fi

        fi
    done

    exec emacsclient -a '' -c -n "${list[@]}"
fi

avail nano && exec nano "$@"
avail vim && exec vim "$@"
avail vi && exec vi "$@"
