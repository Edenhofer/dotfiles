#!/hint/bash

# Configure oh-my-zsh if present and fall back to a custom prompt if not {{{
if [[ -d /usr/share/oh-my-zsh/ || -d "${HOME}/.oh-my-zsh/" ]]; then
	# Path to an oh-my-zsh installation
	if [[ -d /usr/share/oh-my-zsh/ ]]; then
		ZSH=/usr/share/oh-my-zsh/
	else
		ZSH="${HOME}/.oh-my-zsh/"
	fi

	# ZSH theme to load
	# Use a different theme for ssh sessions, containers and local
	if [[ -n "${SSH_CLIENT}" || -n "${SSH_TTY}" ]]; then
		ZSH_THEME="agnoster" # Fancy and colorful
	elif systemd-detect-virt &>/dev/null; then
		ZSH_THEME="agnoster" # Fancy and colorful
	else
		ZSH_THEME="robbyrussell" # Plain and simple
	fi

	# Disable bi-weekly auto-update checks of oh-my-zsh
	DISABLE_AUTO_UPDATE="true"

	# Disable marking untracked VCS files as dirty (speed up repository checks)
	DISABLE_UNTRACKED_FILES_DIRTY="true"

	# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
	# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
	plugins=(vi-mode git dirhistory)

	# Oh-my-zsh caching
	ZSH_CACHE_DIR="${HOME}/.oh-my-zsh-cache"
	if [[ ! -d "${ZSH_CACHE_DIR}" ]]; then
		mkdir "${ZSH_CACHE_DIR}"
	fi

	# Initiate oh-my-zsh
	source "${ZSH}/oh-my-zsh.sh"
else
	# Configure a fallback prompt
	if (( UID != 0 )); then
		username_color="%F{blue}"
	else
		username_color="%F{red}"
	fi
	if [[ -n "${SSH_CLIENT}" || -n "${SSH_TTY}" ]]; then
		# Choose a random color based on the name of the host
		#host_color_palette=("%F{yellow}" "%F{orange}" "%F{cyan}" "%F{magenta}")
		#choice=$(($(RANDOM=${HOST}; echo ${RANDOM}) % ${#host_color_palette[@]}))
		#host_color=${host_color_palette[$choice]}
		host_color="%F{yellow}"
	else
		host_color="%F{green}"
	fi
	path_color="%F{blue}"
	_shpwd() {
		echo ${${:-/${(j:/:)${(M)${(s:/:)${(D)PWD:h}}#(|.)[^.]}}/${PWD:t}}//\/~/\~}
	}

	function zle-line-init zle-keymap-select {
		PROMPT="${username_color}%n%f@${host_color}%B%m%b%f ${path_color}%B$(_shpwd)%b%f > "

		# Tweak the reverse side of PROMPT / PS1 to highlight special vi edit modes and the current git branch
		vim_prompt="%{$fg_bold[yellow]%} [% NORMAL]% %{$reset_color%}"
		RPROMPT="${${KEYMAP/vicmd/$vim_prompt}/(main|viins)/} $(git rev-parse --abbrev-ref HEAD 2>/dev/null) $EPS1"
		zle reset-prompt
	}
	zle -N zle-line-init
	zle -N zle-keymap-select
fi
# }}}

# Keybindings {{{
# Use vim keyboard bindings
bindkey -v

# Make `backspace` and `^h` work after returning from command mode
bindkey '^?' backward-delete-char
bindkey '^h' backward-delete-char

# Use some of emacs' shortcuts to move around
bindkey '^P' up-history
bindkey '^N' down-history
bindkey '^w' backward-kill-word
bindkey '^r' history-incremental-search-backward
bindkey '^H' backward-kill-word
bindkey '\e[3;5~' kill-word
bindkey '\e[1~' beginning-of-line
bindkey '\e[4~' end-of-line
bindkey '\e[3~' delete-char
bindkey '\e[2~' overwrite-mode
bindkey "^[[7~" beginning-of-line	# Pos1
bindkey "^[[8~" end-of-line			# End
bindkey "^[[A" history-beginning-search-backward
bindkey "^[OA" history-beginning-search-backward
bindkey "^[[B" history-beginning-search-forward
bindkey "^[OB" history-beginning-search-forward

# Add edit command line feature ("alt-e")
autoload edit-command-line
zle -N edit-command-line
bindkey '\ee' edit-command-line

[[ -f /usr/share/fzf/key-bindings.zsh ]] && source /usr/share/fzf/key-bindings.zsh
# }}}

# History configuration {{{
HISTFILE="${HOME}/.zsh_history"
HISTSIZE=1000000
SAVEHIST="${HISTSIZE}"

# Ignore duplicates
HISTCONTROL=erasedups
HISTIGNORE='&:exit:logout:clear:history'
# }}}

# Miscellaneous SH and ZSH options {{{
autoload -U colors
colors

setopt noincappendhistory
setopt sharehistory
setopt appendhistory
setopt interactivecomments	# Activate bash-style comments
setopt autocd				# .. -> cd ../
setopt extendedglob			# cd search
setopt print_exit_value		# Print non-zero exit value
setopt hist_ignore_space	# Ignore command starting with a space

setopt correct
# Set a spelling prompt (needs `setopt correct`)
SPROMPT="${SHELL}: Correct ${fg[red]}%R${reset_color} to ${fg[green]}%r${reset_color} ? ([Y]es/[N]o/[E]dit/[A]bort) "

unsetopt beep
unsetopt auto_remove_slash

# Load zmv - a clever mv
autoload -U zmv
alias mmv='noglob zmv -W'
# }}}

# ZSH completion via zstyle {{{
autoload -Uz compinit
compinit

zstyle :compinstall filename "${HOME}/.zshrc"

# Performance tweaks
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "${HOME}/.zcompcache"
zstyle ':completion:*' use-perl on
# Completion colors
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
# Completion order
zstyle ':completion:*' completer _complete _match _approximate
zstyle ':completion:*:match:*' original only
# Ignore completion for commands we don't have
zstyle ':completion:*:functions' ignored-patterns '_*'
# Get rid of .class and .o files for vim
zstyle ':completion:*:vim:*' ignored-patterns '*.(class|o)'
# Show menu when tabbing; pass additional 'yes' to auto-accept first entry
zstyle ':completion:*' menu select
# Pretty completion for kill
zstyle ':completion:*:*:kill:*' command 'ps --forest -u${USER} -o pid,%cpu,tty,cputime,cmd'
# Provide more processes in completion of programs like killall:
zstyle ':completion:*:processes-names' command 'ps c -u ${USER} -o command | uniq'
compdef pkill=killall
# List files by either file, time, size, links, access or inode when completing
zstyle ':completion:*' file-sort file
# Ignore same file on rm
zstyle ':completion:*:(rm|kill|diff):*' ignore-line yes
zstyle ':completion:*:rm:*' file-patterns '*:all-files'
# Strip duplicate slashes
zstyle ':completion:*' squeeze-slashes true
# Ignore current directory when cd ../<TAB>
zstyle ':completion:*:cd:*' ignore-parents parent pwd
# Prevent lost+found directory from being completed
zstyle ':completion:*:cd:*' ignored-patterns '(*/)#lost+found'
# Ignore case when completing
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

# Make some stuff look better
zstyle ':completion:*:descriptions' format "- %{${fg[yellow]}%}%d%{${reset_color}%} -"
zstyle ':completion:*:messages' format "- %{${fg[cyan]}%}%d%{${reset_color}%} -"
zstyle ':completion:*:corrections' format "- %{${fg[yellow]}%}%d%{${reset_color}%} - (%{${fg[cyan]}%}errors %e%{${reset_color}%})"
zstyle ':completion:*:default' select-prompt "%{${fg[yellow]}%}Match %{${fg_bold[cyan]}%}%m%{${fg_no_bold[yellow]}%}  Line %{${fg_bold[cyan]}%}%l%{${fg_no_bold[red]}%}  %p%{${reset_color}%}"
zstyle ':completion:*:default' list-prompt "%{${fg[yellow]}%}Line %{${fg_bold[cyan]}%}%l%{${fg_no_bold[yellow]}%}  Continue?%{${reset_color}%}"
zstyle ':completion:*:warnings' format "- %{${fg_no_bold[red]}%}no match%{${reset_color}%} - %{${fg_no_bold[yellow]}%}%d%{${reset_color}%}"
zstyle ':completion:*' group-name ''

# Sort manual pages into sections
zstyle ':completion:*:manuals' separate-sections true
zstyle ':completion:*:manuals.(^1*)' insert-sections true

# Highlight the original input
zstyle ':completion:*:original' list-colors "=*=${color[red]};${color[bold]}"
# Highlight words like 'esac' or 'end'
zstyle ':completion:*:reserved-words' list-colors "=*=${color[red]}"
# Colorize hostname completion
zstyle ':completion:*:*:*:*:hosts' list-colors "=*=${color[cyan]};${color[bg-black]}"
# Colorize username completion
zstyle ':completion:*:*:*:*:users' list-colors "=*=${color[red]};${color[bg-black]}"
# Colorize processlist for 'kill'
zstyle ':completion:*:*:kill:*:processes' list-colors "=(#b) #([0-9]#) #([^ ]#)*=${color[none]}=${color[yellow]}=${color[green]}"
# }}}

# Loading external ZSH configuration {{{
# ZSH syntax highlighting
if [[ -f /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
	source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
elif [[ -f "${HOME}/.zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]]; then
	source "${HOME}/.zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi
# }}}


# --- # Shell agnostic configuration

# Export a default editor
if command -v nvim &>/dev/null; then
	export EDITOR="nvim"
elif command -v vim &>/dev/null; then
	export EDITOR="vim"
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
alias open="xdg-open"

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

if command -v fzf &>/dev/null; then
	kp() {  # Kill Process
		local pid=$(ps -ef | sed 1d | fzf ${FZF_DEFAULT_OPTS} -m --header='[kill:process]' | awk '{print $2}')

		if [[ "x${pid}" != "x" ]]; then
		  kill -${1:-15} ${pid}
		  kp
		fi
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
