#
# Custom /etc/bash.bashrc file
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
export HISTIGNORE='&:exit:clear:history:logout'

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

# Enable autocolor for various commands through alias
alias ls='ls --color=auto'
alias dir='dir --color=auto'
alias vdir='vdir --color=auto'
alias grep='grep --color=auto'

# Aliasing ls commands
alias l='ls -hF --color=auto'
alias lr='ls -R'  # recursive ls
alias ll='ls -AlhF'
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
	alias snano='sudo nano'
	alias root='sudo su'
	alias reboot='sudo reboot'
	alias halt='sudo halt'
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

# Arch Linux support
if [[ -f /etc/arch-release ]]; then
	if [[ $UID -ne 0 ]]; then
		alias pacman='sudo pacman'
		# -c is used to specify the location of the package caches, adjust it to you liking
		alias paccache='sudo paccache -v -c /var/cache/pacman/pkg -c /var/cache/aur'
		# Finding libraries which where renewed in an update but where the old version is still used, adjust it to your liking
		alias outlib="sudo lsof -e /run/user/1000/gvfs +c 0 | grep 'DEL.*lib' | awk '{ print \$NF }' | sort -u"
		alias outpac="sudo lsof -e /run/user/1000/gvfs +c 0 | grep 'DEL.*lib' | awk '{ print \$NF }' | sed -e 's/.so.*/.so/g' | pacman -Qoq - 2>/dev/null | sort -u"
	else
		# -c is used to specify the location of the package caches, adjust it to you liking
		alias paccache='paccache -v -c /var/cache/pacman/pkg -c /var/cache/aur'
		# Finding libraries which where renewed in an update but where the old version is still used, adjust it to your liking
		alias outlib="lsof -e /run/user/1000/gvfs +c 0 | grep 'DEL.*lib' | awk '{ print \$NF }' | sort -u"
		alias outpac="lsof -e /run/user/1000/gvfs +c 0 | grep 'DEL.*lib' | awk '{ print \$NF }' | sed -e 's/.so.*/.so/g' | pacman -Qoq - 2>/dev/null | sort -u"
	fi
fi

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
if which msfconsole &>/dev/null; then
	# Quiet disables ASCII banner and -x ... auto-connects to msf postgresql database owned by ${USER}
	alias msfconsole="msfconsole --quiet -x \"db_connect ${USER}@msf\""
fi

# Enable fuck support if present
type thefuck &>/dev/null && eval $(thefuck --alias)

# Sort By Size
sbs() {
	du -h --max-depth=1 ${*:-"."} | sort -h
}

# Create directory and cd into it
mcd() { mkdir -p "$1"; cd "$1";}

# Comparing the md5sum of a file "$1" with a given one "$2"
md5check() { md5sum "$1" | grep "$2";}
#}}}

# Top 10 cammands
top10() { history | awk '{a[$4]++ } END{for(i in a){print a[i] " " i}}' | sort -rn | head; }

# Fetching outwards facing IP-adress
ipinfo() {
	[[ -z "$*" ]] && curl ipinfo.io || curl ipinfo.io/$*; echo
}

# grep through more than just plain text files
anygrep() {
	[[ $# -lt 2 ]] && echo "Usage: $FUNCNAME <string to grep for> <filename(s)>" && return 1

	# Preserve the previous IFS (Internal Field Separator) settings
	previous_IFS=${IFS}
	# Solely escape proper spaces not those with baskslashes
	IFS=$(echo -en "\n\b")

	# Loop through parameters and split it into a file_list, grep_parms and the search_string
	file_list=()
	grep_parms=()
	search_string=""
	for arg in ${@}; do
		if [[ ${arg} = \-* ]]; then
			# This matches any parameter starting with an '-'
			grep_parms+=("${arg}")
		elif [[ -z ${search_string} ]]; then
			# This matches the first non grep_parm string in the argument array
			search_string="${arg}"
		else
			file_list+=("${arg}")
		fi
	done
	[[ ${#file_list[@]} -lt 1 ]] && echo "No file specified" && return 2

	# Expect that no match is found, hence the default return code should be one
	return_code=1
	for file in ${file_list[@]}; do
		# Using $(file) is possible as well and it is properly implemented but commented out in the follwing code block
		ext=$(echo ${file##*.}) #ext=$(file -L -p -b ${file}) && ext=${ext%% *}
		case "$ext" in
			odt|ods|odp|sxi) #OpenDocument)
			# An odf file (Open Document Format e.g. odt) is simply a zipped folder in which content.xml contains the actual text in xml in format
			# The sed command removes any content in between angle brackets ('<' and '>'), it is not an ideal solution but it gets the job done
			text=$(unzip -p ${file} content.xml | xmllint --nowarning --format - | sed 's/<[^>]*>//g' | grep --color=always ${grep_parms[@]} "${search_string}")
			;;

			pdf) #PDF)
			# pdftotext and pdfinfo is provided by poppler which should be isntalled if either cups, evince, libreoffice etc. is
			# Search through the properties of a pdf file and the content
			text=$(pdfinfo "${file}" | head -n6 | grep --color=always ${grep_parms[@]} "${search_string}")
			text=${text}$(pdftotext -q "${file}" - | grep --color=always ${grep_parms[@]} "${search_string}")
			;;

			*)
			text=$(grep --color=always ${grep_parms[@]} "${search_string}" "${file}")
			;;
		esac
		# Break if grep reports an error - This must be executed immediately after grep!
		[[ $? -eq 2 ]] && return 2
		# Return 0 if at any point some text was found
		[[ ! -z "${text}" ]] && return_code=0

		# Print merely the matching text in case just one file is opened otherwise print the filename for each hit
		[[ ${#file_list[@]} -eq 1 && ! -z "${text}" ]] && echo "${text}"
		[[ ${#file_list[@]} -gt 1 && ! -z "${text}" ]] && echo -e "\e[35m${file}\e[0m\e[94m:\e[0m${text//$'\n'/$'\n'"\e[35m${file}\e[0m\e[94m:\e[0m"}"
	done

	# Restore previous IFS settings
	IFS=${previous_IFS}

	return ${return_code}
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

# Archive extraction
extract() {
	clrstart="\033[1;34m"  #color codes
	clrend="\033[0m"

	if [[ "$#" -lt 1 ]]; then
		echo -e "${clrstart}Pass a filename. Optionally a destination folder. You can also append a v for verbose output.${clrend}"
		exit 1 #not enough args
	fi

	if [[ ! -e "$1" ]]; then
		echo -e "${clrstart}File does not exist!${clrend}"
		exit 2 #file not found
	fi

	if [[ -z "$2" ]]; then
		DESTDIR="." #set destdir to current dir
	elif [[ ! -d "$2" ]]; then
		echo -e -n "${clrstart}Destination folder doesn't exist or isnt a directory. Create? (y/n): ${clrend}"
		read response
		#echo -e "\n"
		if [[ $response == y || $response == Y ]]; then
			mkdir -p "$2"
			if [ $? -eq 0 ]; then
				DESTDIR="$2"
			else
				exit 6 #Write perms error
			fi
		else
			echo -e "${clrstart}Closing.${clrend}"; exit 3 # n/wrong response
		fi
	else
		DESTDIR="$2"
	fi

	if [[ ! -z "$3" ]]; then
		if [[ "$3" != "v" ]]; then
			echo -e "${clrstart}Wrong argument $3 !${clrend}"
			exit 4 #wrong arg 3
		fi
	fi

	filename=`basename "$1"`

	case "${filename##*.}" in
		tar)
		echo -e "${clrstart}Extracting $1 to $DESTDIR: (uncompressed tar)${clrend}"
		tar x${3}f "$1" -C "$DESTDIR"
		;;
		gz)
		echo -e "${clrstart}Extracting $1 to $DESTDIR: (gip compressed tar)${clrend}"
		tar x${3}fz "$1" -C "$DESTDIR"
		;;
		tgz)
		echo -e "${clrstart}Extracting $1 to $DESTDIR: (gip compressed tar)${clrend}"
		tar x${3}fz "$1" -C "$DESTDIR"
		;;
		xz)
		echo -e "${clrstart}Extracting  $1 to $DESTDIR: (gip compressed tar)${clrend}"
		tar x${3}f -J "$1" -C "$DESTDIR"
		;;
		bz2)
		echo -e "${clrstart}Extracting $1 to $DESTDIR: (bzip compressed tar)${clrend}"
		tar x${3}fj "$1" -C "$DESTDIR"
		;;
		zip)
		echo -e "${clrstart}Extracting $1 to $DESTDIR: (zipp compressed file)${clrend}"
		unzip "$1" -d "$DESTDIR"
		;;
		rar)
		echo -e "${clrstart}Extracting $1 to $DESTDIR: (rar compressed file)${clrend}"
		unrar x "$1" "$DESTDIR"
		;;
		7z)
		echo -e  "${clrstart}Extracting $1 to $DESTDIR: (7zip compressed file)${clrend}"
		7za e "$1" -o"$DESTDIR"
		;;
		*)
		echo -e "${clrstart}Unknown archieve format!"
		exit 5
		;;
	esac
}

# Archive compression
compress() {
	if [[ -n "$1" ]]; then
		FILE=$1
		case $FILE in
			*.tar ) shift && tar cf $FILE $* ;;
			*.tar.bz2 ) shift && tar cjf $FILE $* ;;
			*.tar.gz ) shift && tar czf $FILE $* ;;
			*.tgz ) shift && tar czf $FILE $* ;;
			*.zip ) shift && zip $FILE $* ;;
			*.rar ) shift && rar $FILE $* ;;
		esac
	else
		echo "usage: compress <foo.tar.gz> ./foo ./bar"
	fi
}

# Chromium using tor proxy
tor-chromium() {
	if which chromium &>/dev/null; then
		if which systemctl &>/dev/null; then
			[[ $(systemctl is-active tor) != "active" ]] && systemctl start tor
		else
			echo "Could not verify that Tor is running, please make sure it is. Proceeding anyway!"
		fi
		[[ -d /tmp/cache-edh ]] || mkdir -p /tmp/private-chromium-cache
		torify curl -s ipinfo.io 2>&1 | grep -i "\"ip\"" | sed "s/ip/fake-ip/" | tr -d ",\n"
		echo -n "  |"
		curl -s ipinfo.io 2>&1 | grep -i "\"ip\"" | sed "s/ip/true-ip/" | tr -d ","
		echo -e "\e[1mStarting chromium in incognito modus, keeping the cache in /tmp and using the local tor-proxy.\e[0m"
		chromium --incognito --disk-cache-dir=/tmp/private-chromium-cache --proxy-server="socks://localhost:9050"
	else
		echo "Could not find chromium!"
	fi
}
