
# to use this on a host, add this to the top of the host's .bashrc or .profile:
#. ~/code/settings/bashrc

if [ `/usr/bin/id -u` -eq 0 ] && [ -d /root ] && [ -n "$(find /root -user "root" -print -prune -o -prune 2>/dev/null)" ]; then
	export HOME=/root
elif [ `/usr/bin/id -u` -eq 0 ] && [ -d /var/root ] && [ -n "$(find /var/root -user "root" -print -prune -o -prune 2>/dev/null)" ]; then
	export HOME=/var/root
fi

ORIG_PATH=$PATH
PATH=$HOME/bin:/bin:/sbin:/usr/bin:/usr/sbin:/usr/X11R7/bin:/usr/X11R6/bin
# these prepend paths to PATH, so we're semi-careful and check the owner first
if [ -d /usr/pkg/bin ] && [ -n "$(find /usr/pkg/bin -user "root" -print -prune -o -prune 2>/dev/null)" ]; then
	PATH=/usr/pkg/bin:/usr/pkg/sbin:${PATH}
	# $MANPATH isn't usually set, so this breaks all the default search locations
	#MANPATH=/usr/pkg/man:$MANPATH
elif [ -d "$HOME/pkg/bin" ] && [ -n "$(find "$HOME/pkg/bin" -user "$(id -u)" -print -prune -o -prune)" ]; then
	PATH=$HOME/pkg/bin:$HOME/pkg/sbin:${PATH}
	# $MANPATH isn't usually set, so this breaks all the default search locations
	#MANPATH=$HOME/pkg/man:$MANPATH
fi
PATH=${PATH}:/usr/local/bin:/usr/local/sbin
if echo `uname` | grep -E ^MINGW > /dev/null ; then
	PATH=${PATH}:$ORIG_PATH
fi
export PATH
#export MANPATH

# also add these two lines to /root/.profile (for e.g. 'sudo -i crontab -e')
export EDITOR=vim
alias vi=vim

alias ls='ls -F'

export PAGER=less
alias less='less -R -X'
alias ack='ack --pager="less -R -X" -a'

alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."

# http://www.shellperson.net/using-sudo-with-an-alias/   (fixes "sudo vi <whatever>" not using vim)
alias sudo='sudo '

alias notify='tput bel'

command -v grunt > /dev/null && alias grunt="grunt --stack"

export HISTIGNORE="clear:bg:fg:cd:cd -:exit:date:w:pwd"
# type something then hit up/down to search history that matches what you already have
bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'

if [ "$TERM" = "xterm-256color" ] && [ `uname` != "Darwin" ]; then
	# 256color isn't recognized by too many things, still
	export TERM=xterm-color
fi

if [ -f ~/.prompt_spec ]; then
	. ~/.prompt_spec
elif [ `/usr/bin/id -u` == 0 ]; then
	# red
	export PS1="\[\e[0;31m\][\u@\h \W]$ \[\e[m\]"
else
	# green
	export PS1="\[\e[0;32m\][\u@\h \W]$ \[\e[m\]"
fi

if [ -f ~/.git-completion.bash ]; then
	. ~/.git-completion.bash
fi

# mosh sets this to en_US.UTF-8, which makes perl angry, so do this on mosh servers, if necessary
#unset LANG

export PERL_CPANM_OPT="-v -S"

if ( command -v tty >/dev/null ) && ( tty -s ) && [ -x /usr/games/fortune ]; then
	/usr/games/fortune
fi

NOTEDIR="$HOME/OneDrive/Scratch"
if [ -d "$NOTEDIR" ]; then
	_noteComplete()
	{
		local files=("$NOTEDIR/$2"*)
		[[ -e ${files[0]} ]] && COMPREPLY=( "${files[@]##*/}" )
	}
	complete -o bashdefault -o default -o filenames -F _noteComplete note
fi
