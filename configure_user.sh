#!/usr/bin/env bash

set -eu

# assume we already have a clone of github.com/truist/settings
SETTINGS=src/settings

clear_file() {
	thefile="$1"
	echo "$1..."
	if [ -e "$thefile" ] || [ -L "$thefile" ]; then
		if [ -f "$thefile" ]; then
			mv "$thefile" "${thefile}.prior"
		else
			echo "error: $thefile exists and is not a file" >&2
			exit 1
		fi
	fi
}

cd ~
for nodotfile in bash_profile bashrc gitignore prompt_spec vimrc ; do
	dotfile=".$nodotfile"
	clear_file "$dotfile"
	ln -s "$SETTINGS/$nodotfile" "$dotfile"
done

nodotfile="gitconfig"
dotfile=".$nodotfile"
clear_file "$dotfile"
cat << EOF > "$dotfile"
[include]
	path = $SETTINGS/$nodotfile
EOF

bindir="bin"
relpath=".."
mkdir -p "$bindir"
cd "$bindir"
for scriptfile in do_all master-to-new-branch ; do
	clear_file "$scriptfile"
	ln -s "$relpath/$SETTINGS/$scriptfile" "$scriptfile"
done

cd ~
"$SETTINGS/vim-pathogen.sh"

echo "done!"

