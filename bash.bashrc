#
# Custom bash.bashrc file for the GNU Bourne-Again SHell
# by Gordian Edenhofer
#
# Based on multiple sources with constant tweaking.
#
# Keep it simple, stupid (KISS)
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Set default keybindings to vi
set -o vi

# Changing dircolors
[[ -f $HOME/.dircolors ]] && eval $(dircolors -b $HOME/.dircolors)
[[ -f $HOME/.dircolors_256 ]] && eval $(dircolors -b $HOME/.dircolors_256)

# PS1 configuration
_blue='\[\e[1;38;5;33m\]'
_light_blue='\[\e[1;38;5;81m\]'
_green='\[\e[1;38;5;82m\]'
_grey='\[\e[1;38;5;242m\]'
_light_grey='\[\e[1;38;5;245m\]'
_another_grey='\[\e[1;38;5;242m\]'
_violet='\[\e[1;38;5;93m\]'
_red='\[\e[1;38;5;1m\]'
_orange='\[\e[1;38;5;214m\]'
_no_color='\[\e[0m\]'
if [[ $UID == 0 ]]; then
	# '\${?#"0"}' can be used to display the last return code
	PS1="${_grey}[${_red}\u${_another_grey}@${_another_grey}\h${_another_grey}:${_blue}\W${_another_grey}]${_no_color}# "
else
	PS1="${_grey}[${_orange}\u${_another_grey}@${_another_grey}\h${_another_grey}:${_blue}\W${_another_grey}]${_no_color}$ "
fi

# Shell configuration
shopt -s cdspell        # Correct cd typos
shopt -s checkwinsize   # Update windows size on command
shopt -s histappend     # Append History instead of overwriting file
shopt -s cmdhist        # Bash attempts to save all lines of a multiple-line command in the same history entry
shopt -s extglob        # Extended pattern
#shopt -s no_empty_cmd_completion	# No empty completion

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

# CDPATH lets you quickly switch directories
#[[ -d "$HOME/Projects" ]] && export CDPATH=".:$HOME:$HOME/Projects" || export CDPATH=".:$HOME"

## Extending the PATH
[[ -d /usr/lib/ccache/bin ]] && PATH="/usr/lib/ccache/bin/:$PATH"
[[ -d "$HOME/c" ]] && PATH="$HOME/c:$PATH"
[[ -d "$HOME/bin" ]] && PATH="$HOME/bin:$PATH"
PATH="$PATH:."

# Export the default ditor
if which vim &>/dev/null; then
	export EDITOR="vim"
elif which vi &>/dev/null; then
	export EDITOR="vi"
elif which emacs &>/dev/null; then
	export EDITOR="emacs -nw"
else
	export EDITOR="nano"
fi

# Shell history
export HISTSIZE=5000              # bash history will save N commands
export HISTFILESIZE=${HISTSIZE}   # bash will remember N commands
export HISTTIMEFORMAT="%d. %h %H:%M:%S> "    # add timestamps to each command
export HISTCONTROL=erasedups     # ingore duplicates
export HISTIGNORE='&:exit:logout:clear:history'

# Colored manual pages
# @see http://misc.flogisoft.com/bash/tip_colors_and_formatting for options
#export PAGER=less
#export LESS_TERMCAP_mb=$'\E[01;31m'	# begin blinking
#export LESS_TERMCAP_md=$'\E[01;31m'	# begin bold
#export LESS_TERMCAP_me=$'\E[0m'			# end mode
#export LESS_TERMCAP_se=$'\E[0m'			# end standout-mode
#export LESS_TERMCAP_so=$'\E[34m'			# begin standout-mode - info box
#export LESS_TERMCAP_ue=$'\E[0m'			# end underline
#export LESS_TERMCAP_us=$'\E[04m'			# begin underline

# Colorful less
export LESS='-r'

# Enable autocolor for various commands through alias
alias ls='ls --color=auto'
alias dir='dir --color=auto'
alias vdir='vdir --color=auto'
alias grep='grep --color=auto'

# Aliasing ls commands
alias l='ls -hF --color=auto'
alias lr='ls -R'  # recursive ls
alias ll='ls -alhFv'
alias lh='ls -ahrlt'
alias la='ls -ah'

# Standard aliases
alias ..='cd ..'
alias ...='cd ../..'
alias -- +='pushd .'
alias -- -='popd'
alias li='less -i'
alias p='ps -u `/usr/bin/whoami` -o uid,pid,ppid,class,c,nice,stime,tty,cputime,comm'
alias r='echo $?'
alias c='clear'
alias v='vim'
alias cmount='mount | column -t'
alias meminfo='free -m -l -t'
alias intercept='sudo strace -ff -e trace=write -e write=1,2 -p'
alias listen='lsof -P -i -n'
alias port='netstat -tulanp'
alias genpasswd="strings /dev/urandom | head -n 30 | tr -d '\n' | tr -d '[[:space:]]'; echo"

# Create sudo aliases for various commands
if [[ $UID -ne 0 ]]; then
	alias scat='sudo cat'
	alias svi='sudo vi'
	alias svim='sudo vim'
	alias sv='sudo vim'
	alias sli='sudo less'
	alias snano='sudo nano'
	alias root='sudo su'
	alias reboot='sudo reboot'
fi

# Create shortcuts and sudo aliases for systemd
if which systemctl &>/dev/null; then
	if [[ $UID -ne 0 ]]; then
		alias start='sudo systemctl start'
		alias restart='sudo systemctl restart'
		alias stop='sudo systemctl stop'
		alias enable='sudo systemctl enable'
		alias disable='sudo systemctl disable'
		alias daemon-reload='sudo systemctl daemon-reload'
	else
		alias start='systemctl start'
		alias restart='systemctl restart'
		alias stop='systemctl stop'
		alias enable='systemctl enable'
		alias disable='systemctl disable'
		alias daemon-reload='systemctl daemon-reload'
	fi

	alias status='systemctl status'
	alias list-timers='systemctl list-timers'
	alias list-units='systemctl list-units'
	alias list-unit-files='systemctl list-unit-files'
fi

# Pacman support
if which pacman &>/dev/null; then
	if [[ $UID -ne 0 ]]; then
		alias pacman='sudo pacman'
		alias mkinitcpio='sudo mkinitcpio'
		# A CUSTOM cache location can be specified with '-c', consider this a TODO for you to adjust
		alias paccache='sudo paccache -v -c /var/cache/pacman/pkg -c /var/cache/aur'
		# Finding libraries which where renewed in an update but where the old version is still used
		alias outlib="sudo lsof +c 0 | grep 'DEL.*lib' | awk '{ print \$NF }' | sort -u"
		alias outpac="sudo lsof +c 0 | grep 'DEL.*lib' | awk '{ print \$NF }' | sed -e 's/.so.*/.so/g' | pacman -Qoq - 2>/dev/null | sort -u"
	else
		# A CUSTOM cache location can be specified with '-c', consider this a TODO for you to adjust
		alias paccache='paccache -v -c /var/cache/pacman/pkg -c /var/cache/aur'
		# Finding libraries which where renewed in an update but where the old version is still used
		alias outlib="lsof +c 0 | grep 'DEL.*lib' | awk '{ print \$NF }' | sort -u"
		alias outpac="lsof +c 0 | grep 'DEL.*lib' | awk '{ print \$NF }' | sed -e 's/.so.*/.so/g' | pacman -Qoq - 2>/dev/null | sort -u"
	fi
fi

# Arch Build System (abs) sudo alias
which abs &>/dev/null && [[ $UID -ne 0 ]] && alias abs='sudo abs'

# Support netctl package
if which netctl &>/dev/null; then
	if [[ $UID -ne 0 ]]; then
		alias netctl='sudo netctl'
		alias netctl-auto='sudo netctl-auto'
		alias wifi-menu='sudo wifi-menu'
	fi
fi

# Specialized find alias
alias fibs='find . -not -path "/proc/*" -not -path "/run/*"  -type l -! -exec test -e {} \; -print'
alias fl='find . -type l -exec ls --color=auto -lh {} \;'

# Metasploit Framework
# Quiet disables ASCII banner and -x ... auto-connects to msf postgresql database owned by ${USER}
if which msfconsole systemctl &>/dev/null; then
	alias msfconsole="start postgresql && msfconsole --quiet -x \"db_connect ${USER}@msf\""
elif which msfconsole &>/dev/null; then
	alias msfconsole="msfconsole --quiet -x \"db_connect ${USER}@msf\""
fi

# Enable fuck support if present
which thefuck &>/dev/null && eval $(thefuck --alias)

# Disable R's verbose startup message
which R &>/dev/null && alias R="R --quiet"

# Sort By Size
sbs() {
	du -h --max-depth=1 "${*:-"."}" | sort -h
}

# Create directory and cd into it
mcd() { mkdir -p "$1"; cd "$1";}

# Comparing the md5sum of a file "$1" with a given one "$2"
md5check() { md5sum "$1" | grep "$2";}

# Top 10 cammands
top10() { history | awk '{a[$4]++ } END{for(i in a){print a[i] " " i}}' | sort -rn | head; }

# Fetching outwards facing IP-adress
ipinfo() {
	[[ -z "$*" ]] && curl ipinfo.io || curl ipinfo.io/$*; echo
}

# Explaining Shell Commands in the Shell
explain () {
	if [ "$#" -eq 0 ]; then
		echo -e "USAGE:\texplain [COMMAND]"
	else
		curl -Gs "https://www.mankier.com/api/explain/?cols="$(tput cols) --data-urlencode "q=$*"
	fi
}

# Remind me later
# usage: remindme <time> <text>
# e.g.: remindme 10m "omg, the pizza"
remindme() { sleep $1 && zenity --info --text "$2" & }

# Simple calculator
calc() {
	if which bc &>/dev/null; then
		echo "scale=3; $*" | bc -l
	else
		awk "BEGIN { print $* }"
	fi
}

# Swap two files
swap() {
	local TMPFILE=tmp.$$

	[[ $# -ne 2 ]] && echo "swap: 2 arguments needed" && return 1
	[[ ! -e $1 ]] && echo "swap: $1 does not exist" && return 1
	[[ ! -e $2 ]] && echo "swap: $2 does not exist" && return 1

	mv "$1" $TMPFILE
	mv "$2" "$1"
	mv $TMPFILE "$2"
}
