#!/usr/bin/env bash

set -e

if [[ $# -ne 1 ]] || [[ "$1" == "-h" ]]; then
	cat <<-END >&2
		This script will:
		  - create a new virtualenv (with the default python) with 'pyenv virtualenv'
		  - add a .python-version file so it is automatically picked up by pyenv,
		    if you have the shell integration
		  - add .python-version to the top of a .gitignore file

		args: <virtualenv name>
END
	exit 1
fi

venv_name="$1"

pyenv virtualenv "$venv_name"
echo "$venv_name" >.python-version

touch .gitignore
sed -i '' '1i\
.python-version\
\
' .gitignore

