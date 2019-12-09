# -u — treat unset variables as an error when substituting.
# +H — disable ‘!’-style history substitution
# -C — do not overwrite file with >,  >&, <> redirection

set -u +H -C;



# checkwinsize — check size of window
# failglob — failed globbing raises an error
# globstar — ** matches recursively

shopt -s checkwinsize failglob globstar;



# readline configuration

# https://www.gnu.org/software/bash/manual/html_node/Readline-Init-File-Syntax.html
# Try `help bind`, and `bind -p`

bind 'set show-all-if-ambiguous on'
bind 'set enable-bracketed-paste on'



# history settings

# avoid duplicate entries in history, skip those with leading space
unset HISTIGNORE;
HISTCONTROL='ignoredups,ignorespace';

# max number of lines stored in history
HISTSIZE=5000;
HISTFILESIZE="${HISTSIZE}";



# Defining a nice prompt

function prompt {
    local ec="$?";
    test "$ec" -eq 0 && echo '4;32m' || echo '4;31m';
    return "$ec";
}

test "${UID}" = 0 && suf='#' || suf='$';
if test -t 1 && grep -Eqx 'xterm|screen' <<< "${TERM:-}"; then
    PS1='\[\e]0;\u@\h:\w\a\e[0;$(prompt)\]\u@\h:\w'"${suf}"'\[\e[0m\] ';
    test "${TERM}" = screen && PS1="+${PS1}";
else
    PS1="\$? \u@\h:\w${suf} ";
fi;
unset suf;

PS2='> ';



# change ls colors
test -r /etc/dircolors && eval "$(SHELL="$SHELL" dircolors /etc/dircolors)";



# convenience

alias '..'='cd ..';

mcd () { mkdir -p "$1" && cd "$1"; }



# these functions provide the typo facility

function typo {
  alias "$1"="echo \"$1 is considered a typo of $2; unalias to use.\"; false";
}

# define what's considered a typo
typo ex ec;
typo mc mv;
typo mf mv;
typo xman 'x man';
#typo wget 'curl -O';



# various shorthands

# tune ls
alias ls='ls -T0 --color=auto --si';
alias l='ls -l';
alias la='l -A';
alias ll='rep -SR ls -l --color=always';
alias lla='ll -A';
alias lt='l -tr';
alias lat='la -tr';
alias llt='ll -tr';
alias llat='lla -tr';

# mime type of a file
alias mime='file -b --mime';

# systemctl
alias sc=systemctl
alias scu='sc --user'
alias jc=journalctl
alias jcu='jc --user'


# interaction

function ask_yN {
    local answer='';
    read -n 1 -s -p "$* [yN]" answer;
    if test "${answer}" = y; then
        echo yes;
        return 0;
    fi;
    echo no;
    return 1;
}



# a better version of cd

alias cd=cd_improved;

cd_improved () {
    local tmp;

    if test "${1:-}" = .; then
        OTHER="${PWD}"; shift;
    fi;
    if test "${1:-}"; then
        if test -f "$1"; then
            builtin cd "$(dirname "$1")";
            l "$(basename "$1")";
        else
            builtin cd "${@}";
        fi
    else
        if test "${OTHER:-}"; then
            tmp="${PWD}";
            builtin cd "${OTHER}";
            OTHER="${tmp}";
        else
            OTHER="${PWD}";
            builtin cd;
        fi;
    fi;
}



# a better version of dig

alias dig=dig_improved

dig_improved () {
    command dig +noall +answer +authority +noadditional +ttlunits -tany "$@"
}



# a better version of mv

alias mv=mv_improved;

function mv_improved {
    if test -z "${1:-}"; then
 echo 'This `mv` is a shell alias.';
    elif test "$#" = 1 -a -e "$1"; then
        ls -ld "$1";
        if read -e -p 'new: ' -i "$1" new; then
            test "$1" = "$new" && return 1;
            command mv -i "$1" "$new";
            ls -ld "$new";
        fi;
    else
        command mv "$@";
    fi;
}



# a better version of ln

alias ln=ln_improved;

function ln_improved {
    if test -z "${1:-}"; then
 echo 'This `ln` is a shell alias.';
    elif test "$#" = 1 -a -L "$1"; then
        ls -ld "$1";
        if read -e -p '-> ' -i "$(readlink $1)" new; then
            rm "$1";
            command ln -sf "$new" "$1";
            ls -ld "$1";
        fi;
    else
        command ln "$@";
    fi;
}



# a better version of time

alias time=time_improved;

function time_improved {
    if test -z "${1:-}"; then
        echo 'This `time` is a shell alias.  The original says:';
        command time;
    elif test "${1:0:1}" = '-'; then
        command time "$@";
    else
        command time -f 'usr=%Us ker=%Ss rss=%MkB' "$@";
    fi;
}



# a better version of tmux

alias tmux=tmux_improved;

function tmux_improved {
    if test -z "${1:-}"; then
        echo 'This `tmux` is a shell alias.';
        command tmux a || command tmux;
    else
        command tmux "$@";
    fi;
}




# find largest subdir

function largest {
    echo 'Finding largest files/directories' >&2;
    find . -maxdepth 1 -mindepth 1 -execdir du -sh {} \; | sort -h;
}



# load user's bashrc

test -r ~/.bashrc && source ~/.bashrc;
