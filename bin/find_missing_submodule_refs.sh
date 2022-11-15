#!/bin/sh

set -e

CURBRANCH="$(git branch --show-current)"

sub_status() {
	git submodule status --cached 2>&1 | grep -Ev '\(\S+\)$' || true
}

# for branch in $(git branch -a | grep -v master | grep remotes | grep -Eo 'origin.*') ; do
for branch in $(git branch -a | grep remotes | grep -Eo 'origin\S*') ; do
	git checkout -q "$branch"
	RESULT="$(sub_status)"
	if [ -n "$RESULT" ]; then
		echo "$branch: $RESULT"
		echo ""
	fi
done

git checkout -q "$CURBRANCH"

