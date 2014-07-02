# this file is called by bash when it is run as a login shell,
# and it calls ~/.bashrc, which is called by bash when it is run
# as an interactive non-login shell

if [ -n "$HOME/.bashrc" ]; then . "$HOME/.bashrc"; fi

