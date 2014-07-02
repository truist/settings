# this file is automatically read by bash when it is run as an
# interactive non-login shell, and is called by ~/.profile, which
# is read by bash when it is run as a login shell

export EDITOR=vim
alias vi=vim

alias ls='ls -F'

export HISTIGNORE="clear:bg:fg:cd:cd -:exit:date:w:pwd"

export PAGER=less
alias less='less -R'
alias ack='ack --pager="less -R -X" -a'

if [ "$TERM" == "xterm-256color" ]; then
	export TERM=xterm-color
fi

if [ "$TERM" == "screen" ]; then
        # make tmux show useful stuff in the status line
        export PROMPT_COMMAND="echo -ne \"\\033]0;\${USER}@${HOSTNAME}\\007\\033k\${PWD}\\033\\\\\""
fi

if [ `/usr/bin/id -u` == 0 ]; then
	export HOME=/root
	# red
	export PS1="\[\e[0;31m\][\u@\h \W]$ \[\e[m\]"
else
	# green
	export PS1="\[\e[0;32m\][\u@\h \W]$ \[\e[m\]"
fi

source ~/.prompt_spec

# mosh sets this to en_US.UTF-8, which makes perl angry
unset LANG

export PERL_CPANM_OPT="-v -S"

if ( tty -s ); then
	/usr/games/fortune
fi

