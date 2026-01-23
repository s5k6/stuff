# -u — treat unset variables as an error when substituting.
# +H — disable ‘!’-style history substitution
# -C — do not overwrite file with >,  >&, <> redirection

set -u +H -C



# checkwinsize — check size of window
# failglob — failed globbing raises an error
# globstar — ** matches recursively

shopt -s checkwinsize failglob nullglob globstar



# Readline configuration.  # Try `help bind`, and `bind -p`.
# https://www.gnu.org/software/bash/manual/html_node/Readline-Init-File-Syntax.html

bind 'set show-all-if-ambiguous on'
bind 'set enable-bracketed-paste on'



# history settings

# avoid duplicate entries in history, skip those with leading space
HISTCONTROL='ignoredups:ignorespace'
HISTIGNORE='reboot*:poweroff*'

# max number of lines stored in history
HISTSIZE=5000
HISTFILESIZE="${HISTSIZE}"



# Defining a nice prompt

if test -t 1 && grep -Eqx 'xterm' <<< "${TERM:-}"; then
    PS1='\[\e]0;\u@\h:\w\a\e[0;4;$(
if test "$?" -eq 0; then echo 32; else echo 31; fi
)m\]\u@\h:\w\$\[\e[0m\] '
else
    PS1='\u@\h:\w\$ '
fi

PS2='> '



# change ls colors

if test /etc/dircolors -nt /etc/dircolors.bash; then
    echo 'Please update: dircolors -b /etc/dircolors >| /etc/dircolors.bash'
fi

source /etc/dircolors.bash
LS_COLORS+=':*readline-colored-completion-prefix=47'



# various shorthands

unalias -a   # Only allow my aliases

# define what's considered a typo
function typo {
  alias "$1"="echo \"$1 is considered a typo of $2; unalias to use.\"; false"
}
typo ex ec
typo mc mv
typo mf mv
typo xman 'x man'
typo pkgfile 'pacman -F'

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

# mime type of a file
alias mime='file -b --mime'

# systemctl
alias sc=systemctl
alias scu='sc --user'
alias jc=journalctl
alias jcu='jc --user'

# do not overwrite target when moving
alias mv='mv -i'
alias cp='cp -i'

# changing directories
alias '..'='cd ..'
mcd () { mkdir -p "$1" && cd "$1"; }



# a better version of cd

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



# find largest subdir

function largest {
    echo 'Finding largest files/directories' >&2
    find . -maxdepth 1 -mindepth 1 -execdir du -sh {} \; | sort -h
}



# side-by-side diff, matching terminal width

function diffy {
    diff -y -W "${COLUMNS}" "$@"
}



# load user's bashrc

if test -r ~/.bashrc; then source ~/.bashrc; fi
