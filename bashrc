
# to use this on a host, add this to the top of the host's .bashrc or .profile:
#. code/settings/bashrc

# this file is automatically read by bash when it is run as an
# interactive non-login shell, and is called by ~/.profile, which
# is read by bash when it is run as a login shell

if [ `/usr/bin/id -u` -eq 0 ] && [ -d /root ] && [ -n "$(find /root -user "root" -print -prune -o -prune > 2>/dev/null)" ]; then
	export HOME=/root
fi

PATH=$HOME/bin:/bin:/sbin:/usr/bin:/usr/sbin:/usr/X11R7/bin:/usr/X11R6/bin
# these prepend paths to PATH, so we're semi-careful and check the owner first
if [ -d /usr/pkg/bin ] && [ -n "$(find . -user "root" -print -prune -o -prune > 2>/dev/null)" ]; then
	PATH=/usr/pkg/bin:/usr/pkg/sbin:${PATH}
	MANPATH=/usr/pkg/man:$MANPATH
elif [ -d "$HOME/pkg/bin" ] && [ -n "$(find . -user "$(id -u)" -print -prune -o -prune)" ]; then
	PATH=$HOME/pkg/bin:$HOME/pkg/sbin:${PATH}
	MANPATH=$HOME/pkg/man:$MANPATH
fi
PATH=${PATH}:/usr/local/bin:/usr/local/sbin
export PATH
export MANPATH

# also add these two lines to /root/.profile (for e.g. 'sudo -i crontab -e')
export EDITOR=vim
alias vi=vim

# http://www.shellperson.net/using-sudo-with-an-alias/   (fixes "sudo vi <whatever>" not using vim)
alias sudo='sudo '

alias ls='ls -F'

export HISTIGNORE="clear:bg:fg:cd:cd -:exit:date:w:pwd"
# type something then hit up/down to search history that matches what you already have
bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'

export PAGER=less
alias less='less -R -X'
alias ack='ack --pager="less -R -X" -a'

if [ "$TERM" == "xterm-256color" ]; then
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

# mosh sets this to en_US.UTF-8, which makes perl angry
unset LANG

export PERL_CPANM_OPT="-v -S"

if ( tty -s ) && [ -x /usr/games/fortune ]; then
	/usr/games/fortune
fi

