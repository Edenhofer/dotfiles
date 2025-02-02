#!/hint/bash

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Set default keybindings to vi
set -o vi

# Changing dircolors
[[ -f ${HOME}/.dircolors ]] && eval "$(dircolors -b "${HOME}/.dircolors")"
[[ -f ${HOME}/.dircolors_256 ]] && eval "$(dircolors -b "${HOME}/.dircolors_256")"

# PS1 configuration
_blue='\[\e[1;38;5;33m\]'
_light_blue='\[\e[1;38;5;81m\]'
_green='\[\e[1;38;5;82m\]'
_grey='\[\e[1;38;5;242m\]'
_light_grey='\[\e[1;38;5;245m\]'
_another_grey='\[\e[1;38;5;242m\]'
_violet='\[\e[1;38;5;93m\]'
_red='\[\e[1;38;5;1m\]'
_yellow='\[\e[1;38;5;214m\]'
_no_color='\[\e[0m\]'
_shpwd() {
    dir=${PWD%/*} && last=${PWD##*/}
	res=$(for i in ${dir//\// }; do echo -n "${i:0:1}/" ; done)
    echo "/${res}${last}"
}
if (( UID == 0 )); then
	host_color="${_red}"
	prompt_sign="# "
elif [[ -n "${SSH_CLIENT}" || -n "${SSH_TTY}" ]]; then
	host_color="${_yellow}"
	prompt_sign="> "
else
	host_color="${_green}"
	prompt_sign="> "
fi
# '\${?#"0"}' can be used to display the last return code
PS1="${_grey}${host_color}\u${_another_grey}@${_another_grey}\h${_another_grey} ${_blue}\$(_shpwd)${_another_grey} ${_no_color}${prompt_sign}"

# Shell configuration
shopt -s cdspell        # Correct cd typos
shopt -s checkwinsize   # Update windows size on command
shopt -s histappend     # Append History instead of overwriting file
shopt -s cmdhist        # Bash attempts to save all lines of a multiple-line command in the same history entry
shopt -s extglob        # Extended pattern
#shopt -s no_empty_cmd_completion	# No empty completion

# Search backwards for commands beginning with the characters before the cursor
bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'

[[ -f /usr/share/fzf/key-bindings.bash ]] && source /usr/share/fzf/key-bindings.bash

# Completion
complete -cf sudo
complete -cf man
complete -cf type
complete -cf which
complete -cf time
complete -cf watch
[[ -f /etc/bash_completion ]] && source /etc/bash_completion
[[ -f /usr/share/git/completion/git-completion.bash ]] && source /usr/share/git/completion/git-completion.bash
[[ -f /usr/share/doc/pkgfile/command-not-found.bash ]] && source /usr/share/doc/pkgfile/command-not-found.bash

# Shell history
export HISTSIZE=5000              # bash history will save N commands
export HISTFILESIZE=${HISTSIZE}   # bash will remember N commands
export HISTTIMEFORMAT="%d. %h %H:%M:%S> "    # add timestamps to each command

# Ignore duplicates
HISTCONTROL=erasedups
HISTIGNORE='&:exit:logout:clear:history'


# --- # Shell agnostic configuration

# Export a default editor
if command -v nvim &>/dev/null; then
	export EDITOR="nvim"
	export DIFFPROG="nvim -d"
elif command -v vim &>/dev/null; then
	export EDITOR="vim"
	export DIFFPROG="vim -d"
elif command -v vi &>/dev/null; then
	export EDITOR="vi"
elif command -v emacs &>/dev/null; then
	export EDITOR="emacs -nw"
else
	export EDITOR="nano"
fi
export VISUAL="${EDITOR}"

# Pretty less
export PAGER="less"
export LESSCHARSET="UTF-8"
export LESS='-i -n -w -M -R -P%t?f%f \
:stdin .?pb%pb\%:?lbLine %lb:?bbByte %bb:-...'

# Extending the PATH
[[ -d "${HOME}/.pixi/bin" ]] && export PATH="${HOME}/.pixi/bin:${PATH}"
[[ -d /usr/lib/ccache/bin ]] && export PATH="/usr/lib/ccache/bin/:${PATH}"
export PATH="${PATH}:."
[[ -d "${HOME}/.local/bin" ]] && export PATH="${HOME}/.local/bin:${PATH}"
[[ -d "${HOME}/bin" ]] && export PATH="${HOME}/bin:${PATH}"

# Alter the GOPATH
export GOPATH="${HOME}/.go"

# Speed up switching to vim mode
export KEYTIMEOUT=1 # Lower recognition threshold to 10ms for key sequences

# Enable GPG support for various command line tools
export GPG_TTY=$(tty)
# Refresh gpg-agent tty for non-ssh connections in case the user switches into a X session
[[ -z "${SSH_CLIENT}" && -z "${SSH_TTY}" ]] && gpg-connect-agent updatestartuptty /bye >/dev/null

# Cope with very old remote systems not recognizing a modern TERM
if [[ -n "${SSH_CLIENT}" || -n "${SSH_TTY}" ]]; then
	TERM="screen-256color" # Assume GNU screen is universally recognized
fi

# 'Command not found' completion
command_not_found_handler() {
	local pkgs cmd=$1
	local FUNCNEST=10

	set +o verbose

	if command -v pkgfile >/dev/null; then
		[[ -n "${BASH_VERSION}" ]] && mapfile -t pkgs < <(pkgfile -bv -- "$cmd" 2>/dev/null)
		[[ -n "${ZSH_VERSION}" ]] && pkgs=(${(f)"$(pkgfile -b -v -- "$cmd" 2>/dev/null)"})
	fi

	if [[ -n "${pkgs[*]}" ]]; then
		printf '%s may be found in the following packages:\n' "${cmd}"
		printf '  %s\n' "${pkgs[@]}"
		return 0
	else
		>&2 printf '%s: command not found: %s\n' "${SHELL}" "${cmd}"
		return 127
	fi
}
command_not_found_handle() { command_not_found_handler "$@"; }

# Enable autocolor for various commands through alias
alias ls='ls --color=auto'
alias grep='grep --color=auto'

# Aliasing ls commands
alias l='ls -hF --color=auto'
alias lr='ls -R'  # recursive ls
alias ll='ls -AlhFv'
alias lh='ls -Ahrlt'
alias la='ls -Ah'

# Standard aliases
alias ..='cd ..'
alias ...='cd ../..'
alias -- +='pushd .'
alias -- -='popd'
alias li='less -i'
alias p='ps -u `/usr/bin/whoami` -o uid,pid,ppid,class,c,nice,stime,tty,cputime,comm'
alias r='echo $?'
alias c='clear'
alias v="${EDITOR}"  # Use either neovim, vim or vi
alias g="git"
alias cmount='mount | column -t'
alias meminfo='free -m -l -t'
alias intercept='sudo strace -ff -e trace=write -e write=1,2 -p'
alias listen='lsof -P -i -n'
alias port='ss -tulanp'
alias genpasswd="openssl rand -base64 128"

# Create sudo aliases for various commands
if (( UID != 0 )); then
	alias scat='sudo cat'
	alias sv='sudo ${EDITOR}'
	alias sll='sudo ls -AlhFv'
	alias sli='sudo less'
	alias sport='sudo ss -tulanp'
	alias snano='sudo nano'
	alias reboot='sudo reboot'
fi

# Create shortcuts and sudo aliases for systemd
if command -v systemctl &>/dev/null; then
	if (( UID != 0 )); then
		alias start='sudo systemctl start'
		alias restart='sudo systemctl restart'
		alias stop='sudo systemctl stop'
		alias daemon-reload='sudo systemctl daemon-reload'
	else
		alias start='systemctl start'
		alias restart='systemctl restart'
		alias stop='systemctl stop'
		alias daemon-reload='systemctl daemon-reload'
	fi

	alias status='systemctl status'
	alias list-timers='systemctl list-timers'
	alias list-units='systemctl list-units'
	alias list-unit-files='systemctl list-unit-files'
fi

if !command -v open &>/dev/null; then
	open() {
		# TODO: Better; create a fifo to store the errors and print them if the
		# processes exits with a non-zero return value (FIFO has a default max
		# capacity so there is no need to harden against overflows)
		2>/dev/null xdg-open "${@}" &
	}
fi

if command -v fzf &>/dev/null; then
	fcd() {
		local fzf_opts=()
		(( $# != 0 )) && fzf_opts=('-q' "${*}")
		cd "$(fzf --walker=dir ${fzf_opts[@]})"
	}
	alias cdf="fcd"

	kp() {  # Kill Process
		local fzf_opts=()
		(( $# != 0 )) && fzf_opts=('-q' "${*}")
		local pid=$(ps -ef | sed 1d | fzf ${FZF_DEFAULT_OPTS} "${fzf_opts[@]}" -m --header='[kill:process]' | awk '{print $2}')

		if [[ "x${pid}" != "x" ]]; then
		  kill -15 ${pid}
		  kp
		fi
	}

	fopen() {  # Open by fuzzy search
		local fzf_opts=()
		(( $# != 0 )) && fzf_opts=('-q' "${*}")
		open "$(fzf "${fzf_opts[@]}")"
	}
fi

# Package manager aliases and utilities (especially pacman)
if command -v pacman &>/dev/null; then
	if (( UID != 0 )); then
		alias pacman='sudo pacman'
		alias mkinitcpio='sudo mkinitcpio'
		# A custom cache location can be specified with '-c'; consider this a TODO for you to adjust
		alias paccache='sudo paccache -v -c /var/cache/pacman/pkg -c /var/cache/aur'
		# Find libraries which were renewed in an update but the old version is still used
		alias outlib='sudo lsof -d DEL | awk "\$8~/\/usr\/lib/ { print \$NF }" | sort -u'
		alias outproc="sudo lsof -d DEL +c0 | awk '\$8~/\/usr\/lib/ && !x[\$NF\$1]++ { print \$NF, \$1; }' | column -t"
	else
		# A custom cache location can be specified with '-c'; consider this a TODO for you to adjust
		alias paccache='paccache -v -c /var/cache/pacman/pkg -c /var/cache/aur'
		# Find libraries which were renewed in an update but the old version is still used
		alias outlib='lsof -d DEL | awk "\$8~/\/usr\/lib/ { print \$NF }" | sort -u'
		alias outproc="lsof -d DEL +c0 | awk '\$8~/\/usr\/lib/ && !x[\$NF\$1]++ { print \$NF, \$1; }' | column -t"
	fi
fi
outserve() {
	(( UID == 0 )) && local lsof_cmd=('lsof') || local lsof_cmd=('sudo' 'lsof')

	local pids=($("${lsof_cmd[@]}" -d DEL | awk '$8~/\/usr\/lib/ { print $2 }'))
	(( ${#pids[@]} > 0 )) && { ps -o unit= "${pids[@]}" | sort -u; } || return 0
}

# Support netctl commands if available
if command -v netctl &>/dev/null; then
	if (( UID != 0 )); then
		alias netctl='sudo netctl'
		alias netctl-auto='sudo netctl-auto'
		alias wifi-menu='sudo wifi-menu'
	fi
fi

# Specialized find alias
alias fibs='find . -not -path "/proc/*" -not -path "/run/*" -type l -! -exec test -e {} \; -print'
alias fl='find . -type l -exec ls --color=auto -lh {} \;'

# Metasploit Framework
# Quiet disables ASCII banner and -x ... auto-connects to msf postgresql database owned by ${USER}
if command -v msfconsole systemctl &>/dev/null; then
	alias msfconsole='start postgresql && msfconsole --quiet -x "db_connect ${USER}@msf"'
elif command -v msfconsole &>/dev/null; then
	alias msfconsole='msfconsole --quiet -x "db_connect ${USER}@msf"'
fi

# Enable fuck support if present
command -v thefuck &>/dev/null && eval "$(thefuck --alias)"

# Disable R's verbose startup message
command -v R &>/dev/null && alias R="R --quiet"

# Sort By Size
sbs() {
	du -h --max-depth=1 "${@:-"."}" | sort -h
}

# Create directory and cd into it
mcd() { mkdir -p "$1" && cd "$1"; }

# Comparing the md5sum of a file "$1" with a given one "$2"
md5check() { md5sum "$1" | grep "$2";}

# Escape odd paths containing special characters to make them reusable as shell input
escape() { printf '%q\n' "${@}"; }

# Fetching outwards facing IP-address
ipinfo() {
	if [[ -z "$*" ]]; then
		curl ipinfo.io
	else
		curl ipinfo.io/"$*"
	fi
	echo
}

# Remind me later
# usage: remindme <time> <text>
# e.g.: remindme 10m "omg, the pizza"
remindme() { sleep "$1" && zenity --info --text "$2" & }

# Simple calculator
calc() {
	if command -v bc &>/dev/null; then
		echo "scale=3; $*" | bc -l
	else
		awk "BEGIN { print $* }"
	fi
}

# Swap two files
swap() {
	local TMPFILE=tmp.$$

	[[ $# -ne 2 ]] && echo "swap: 2 arguments needed" && return 1
	[[ ! -e "$1" ]] && echo "swap: $1 does not exist" && return 1
	[[ ! -e "$2" ]] && echo "swap: $2 does not exist" && return 1

	mv "$1" "${TMPFILE}"
	mv "$2" "$1"
	mv "${TMPFILE}" "$2"
}
