#!/usr/bin/env bash

# set -e

if [ -n "$(git status --porcelain)" ]; then
	echo "Please clean your working directory first" >&2
	git status
	exit 1
fi

CURBRANCH="$(git branch --show-current)"

git fetch --prune

cleanup() {
	echo ""
	git checkout -q -f "$CURBRANCH"
	git reset --hard
	git submodule update
	git clean -d -x -f -f
	exit
}
trap cleanup 2

for branch in $(git branch -a --sort=-committerdate | grep remotes | grep -Eo 'origin\S*') ; do
	git checkout -f -q "$branch" >/dev/null 2>&1
	if git submodule update >/dev/null 2>&1 ; then
		echo -n '.'
	else
		echo ""
		echo "$branch:"
		git submodule status --cached | grep -E '\(\)'
	fi
done

cleanup


