# this file is automatically read by bash when it is run as an
# interactive non-login shell, and is called by ~/.profile, which
# is read by bash when it is run as a login shell

PATH=$HOME/bin:/bin:/sbin:/usr/bin:/usr/sbin:/usr/X11R7/bin:/usr/X11R6/bin:/usr/pkg/bin
PATH=${PATH}:/usr/pkg/sbin:/usr/games:/usr/local/bin:/usr/local/sbin
export PATH

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
alias less='less -R'
alias ack='ack --pager="less -R -X" -a'

if [ "$TERM" == "xterm-256color" ]; then
	# 256color isn't recognized by too many things, still
	export TERM=xterm-color
fi

if [ `/usr/bin/id -u` == 0 ]; then
	export HOME=/root
fi
if [ -f ~/.prompt_spec ]; then
	source ~/.prompt_spec
elif [ `/usr/bin/id -u` == 0 ]; then
	# red
	export PS1="\[\e[0;31m\][\u@\h \W]$ \[\e[m\]"
else
	# green
	export PS1="\[\e[0;32m\][\u@\h \W]$ \[\e[m\]"
fi

if [ -f ~/.git-completion.bash ]; then
	source ~/.git-completion.bash
fi

# mosh sets this to en_US.UTF-8, which makes perl angry
unset LANG

export PERL_CPANM_OPT="-v -S"

if ( tty -s ); then
	/usr/games/fortune
fi

