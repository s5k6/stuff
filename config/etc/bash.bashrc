# -u — treat unset variables as an error when substituting.
# +H — disable ‘!’-style history substitution
# -C — do not overwrite file with >,  >&, <> redirection

set -u +H -C



# checkwinsize — check size of window
# failglob — failed globbing raises an error
# globstar — ** matches recursively
# nullglob — temporarily disable failglob for glob to yield empty

shopt -s checkwinsize failglob nullglob globstar



# history settings

# avoid duplicate entries in history, skip dangerous ones
HISTCONTROL='ignoredups:ignorespace'
HISTIGNORE='reboot*:poweroff*'

# max number of lines stored in history
HISTSIZE=5000
HISTFILESIZE="${HISTSIZE}"



# Defining a nice prompt

PROMPT_COMMAND=()

function prompt {
    local ec="$?"
    test "$ec" -eq 0 && echo '4;32m' || echo '4;31m'
    return "$ec"
}

test "${UID}" = 0 && suf='#' || suf='$'
if test -t 1 && ( test "${TERM}" = xterm || test "${TERM}" = screen ); then
    PS1='\[\e]0;\u@\h:\w\a\e[0;$(prompt)\]\u@\h:\w'"${suf}"'\[\e[0m\] '
    test "${TERM}" = screen && PS1="+${PS1}"
else
    PS1="\$? \u@\h:\w${suf} "
fi
unset suf

PS2='> '



# change ls colors

if test /etc/dircolors -nt /etc/dircolors.bash; then
    echo 'Please update: dircolors -b /etc/dircolors >| /etc/dircolors.bash'
fi

source /etc/dircolors.bash



# Only allow my aliases

unalias -a



# these functions provide the typo facility

function typo {
  alias "$1"="echo \"$1 is considered a typo of $2; unalias to use.\"; false"
}

# define what's considered a typo
typo ex ec
typo mc mv
typo mf mv
typo pkgfile 'pacman -F'



# various shorthands

# tune ls
alias ls='ls -T0 --color=auto --si'
alias l='ls -l'
alias la='l -A'
alias ll='rep -SR ls -l --color=always'
alias lla='ll -A'
alias lt='l -tr'
alias lat='la -tr'
alias llt='ll -tr'
alias llat='lla -tr'

# changing directories
alias '..'='cd ..'

# mime type of a file
alias mime='file -b --mime'

# careful on moving and copying
alias mv='mv -i'
alias cp='cp -i'

# systemctl
alias sc=systemctl
alias scu='sc --user'
alias jc=journalctl
alias jcu='jc --user'

# side-by-side adapt to columns
alias diffy='diff -y -W"$COLUMNS"'
alias diffyd='diffy --suppress-common-lines'



# a better version of cd

alias '..'='cd ..'
mcd () { mkdir -p "$1" && cd "$1"; }

cd_improved () {
    local tmp

    if test "${1:-}" = .; then
        OTHER="${PWD}"; shift
    fi
    if test "${1:-}"; then
        if test -f "$1"; then
            builtin cd "$(dirname "$1")"
            l "$(basename "$1")"
        else
            builtin cd "${@}"
        fi
    else
        if test "${OTHER:-}"; then
            tmp="${PWD}"
            builtin cd "${OTHER}"
            OTHER="${tmp}"
        else
            OTHER="${PWD}"
            builtin cd
        fi
    fi
}
alias cd=cd_improved


# more helpers related to cd_improved

function mvo {
    if test -d "${OTHER-}"; then
        mv -t "${OTHER}" "${@}"
    else
        echo 'No OTHER directory.'
        return 1
    fi
}

function cpo {
    if test -d "${OTHER-}"; then
        cp -t "${OTHER}" "${@}"
    else
        echo 'No OTHER directory.'
        return 1
    fi
}



# more useful killall with repetition

function killall_improved {
    echo 'This shell alias repeats killall until it fails.'
    while command killall "$@"; do
        echo 'ok, repeat'
        sleep 1
    done
}
alias killall=killall_improved



# find largest subdir

function largest {
    local last
    echo 'Finding largest files/directories' >&2
    find "${1-.}" -maxdepth 1 -mindepth 1 -print0 | xargs -0 du -sh | sort -h
}



# what does this run

function t {
    p="$(type -p "${1}")"
    if test -z "${p}"; then
        type "${1}"
    else
        r="$(realpath "${p}")"
        ls -l "${p}" "${r}"
        file -b "${r}"
        it="${r}"
    fi
}
