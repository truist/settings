#!/usr/bin/env sh

# This script blocks attempts to call it from an interactive shell,
# but just passes through to the "real" script/program for non-interactive
# shells. Use it to train yourself to use e.g. `ag` instead of `grep` by
# symlinking this script to `grep` somewhere early on your PATH
# (e.g. `~/bin/grep`). Configure the name of the new program via env var, e.g.:
# export WRAP_SUGGEST_grep="ag"

set -eu

cmd_name="$(basename -- "$0")"


# Find the "real" binary with the same name later on PATH.
find_real() {
	# get a version of PATH that doesn't include our current directory
	self_dir="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd -P)"
	clean_path=''
	OLD_IFS=$IFS; IFS=:
	for d in $PATH; do
		[ "$d" = "$self_dir" ] && continue

		# Skip empty PATH segments (which mean ".") to reduce surprises
		[ -z "$d" ] && continue

		if [ -z "$clean_path" ]; then
			clean_path="$d"
		else
			clean_path="$clean_path:$d"
		fi
	done
	IFS=$OLD_IFS

	# Use command -v under that sanitized PATH
	PATH="$clean_path"
	command -v -- "$cmd_name" 2>/dev/null || true
}

# Only if *all* of stdin/stdout/stderr are a TTY do we treat it as interactive
if ( [ ! -t 0 ] || [ ! -t 1 ] || [ ! -t 2 ] ) || [ "${WRAP_BYPASS:-0}" = "1" ]; then
	real="$(find_real)"
	if [ -z "$real" ]; then
		printf 'cannot locate real %s later on PATH (%s)\n' "$cmd_name" "$clean_path" >&2
		exit 127
	fi

	# ensure that all descendants also bypass
	WRAP_BYPASS=1 export WRAP_BYPASS

	# Exec replaces this process; stdin/stdout/stderr pass through unchanged.
	exec "$real" "$@"
else
	per_cmd_var="WRAP_SUGGEST_${cmd_name}"
	suggestion="${WRAP_SUGGEST:-}"
	# shellcheck disable=SC2086
	eval "ptmp=\${$per_cmd_var-}"; [ -n "${ptmp:-}" ] && suggestion="$ptmp"

	if [ -n "$suggestion" ]; then
		printf '`%s` is disabled for interactive use. Use `%s` instead.\n' "$cmd_name" "$suggestion" >&2
	else
		printf '`%s` is disabled for interactive use.\n' "$cmd_name" >&2
		printf '(hint: set WRAP_SUGGEST_%s=foo to have this error suggest an alternative)' "$cmd_name" >&2
	fi
	exit 126
fi

