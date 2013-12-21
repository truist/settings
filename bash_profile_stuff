
export EDITOR=vim
alias vi=vim

export HISTIGNORE="clear:bg:fg:cd:cd -:exit:date:w:pwd"

alias ack='ack --pager="less -R -X" -a'
alias less='less -R -W -X'

source ~/.prompt_spec

# mosh sets this to en_US.UTF-8, which makes perl angry
unset LANG

# pkgsrc
export PATH=/Users/truist/pkg/bin:$PATH
export MANPATH=/Users/truist/pkg/man:$MANPATH
make()
{
	local _MK
	_MK=mk/bsd.pkg.mk
	if [ -f ../../$_MK -o -f ../$_MK -o -f $_MK ]; then
		bmake "$@"
	else
		/usr/bin/make "$@"
	fi
}
