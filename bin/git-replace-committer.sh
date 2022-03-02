#!/bin/sh
# shellcheck disable=SC2034

set -e

if [ $# -lt 3 ]; then
	echo "args: <old email> <new email> <new name> [additional filter-branch args]" >&2
	exit 1
fi

OLD_EMAIL="$1" ; shift
NEW_EMAIL="$1" ; shift
NEW_NAME="$1" ; shift

FILTER_BRANCH_SQUELCH_WARNING=1 git filter-branch --env-filter "
if [ \"\$GIT_COMMITTER_EMAIL\" = \"$OLD_EMAIL\" ]; then
    export GIT_COMMITTER_EMAIL=\"$NEW_EMAIL\"
    export GIT_COMMITTER_NAME=\"$NEW_NAME\"
fi

if [ \"\$GIT_AUTHOR_EMAIL\" = \"$OLD_EMAIL\" ]; then
    export GIT_AUTHOR_EMAIL=\"$NEW_EMAIL\"
    export GIT_AUTHOR_NAME=\"$NEW_NAME\"
fi
" "$@"
