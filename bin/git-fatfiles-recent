#!/usr/bin/env bash

set -e

if [[ $# -lt 1 ]]; then
	echo "args: <number of days to look back> [<number of results to show>]" >&2
	exit 1
fi

DAYS=$1
RESULTS=${2-20}

echo -e "lines\tcurrent"
echo -e "added\tsize\t\tpath"
git log --since="$DAYS days ago" --diff-filter=AM --numstat | sort -nr | head -n "$RESULTS" | awk '{print $1, $3}' |
	while read -r added path; do
		size=$(stat -f "%z" "$path")
		echo -e "$added\t$size\t$path"
	done

