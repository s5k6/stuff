#!/bin/bash
# Copyright 2019 Stefan Klinger <http://stefan-klinger.de>
set -u -e -C;
shopt -s nullglob;

function err { echo $'\e[1;31m'"$@"$'\e[m' >&2; exit 1; }
function warn { echo $'\e[1;35m'"$@"$'\e[m' >&2; }
function info { echo $'\e[36m'"$@"$'\e[m'; }

function ask_yN {
    local answer='';
    read -n 1 -s -p $'\e[34m'"$* [yN]"$'\e[m' answer;
    if test "${answer}" = y; then
        info yes;
        return 0;
    fi;
    info no;
    return 1;
}


zathura=();
less=();
geeqie=();
mplayer=();
loffice=();

for f in "$@"; do

    if test -f "$f"; then

        mime="$(file -L -b --mime-type "$f")";
        suf="${f##*.}";

        case "$mime" in
            #application/pdf) zathura+=("$f");;
            application/pdf) firefox -new-window "$f"&;;
            application/vnd*) loffice+=("$f");;
            audio/*) mplayer+=("$f");;
            image/*) geeqie+=("$f");;
            text/html) firefox -new-window "$f"&;;
            text/*) less+=("$f");;
            video/*) mplayer+=("$f");;
            *) info "Unknown ${mime}: $f";;
        esac;

    else
        warn "Not a file: $f";
    fi;

done;



test "${zathura[*]}" && zathura "${zathura[@]}" &

if test "${less[*]}"; then
    for i in "${less[@]}"; do x less "$i"; done;
fi;

test "${geeqie[*]}" && geeqie "${geeqie[@]}" &

test "${mplayer[*]}" && x mplayer "${mplayer[@]}";

test "${loffice[*]}" && loffice "${loffice[@]}"&
