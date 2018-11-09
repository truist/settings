#!/usr/bin/env bash

set -e
set -o pipefail

usage() {
	echo "usage:" >&2
	echo "  $0 <name> ping <host>" >&2
	echo "  $0 <name> server <port>" >&2
	echo "  $0 <name> client <host> <port>" >&2
	echo "  $0 <name> command <command> [...]" >&2
	echo "" >&2
	echo "    name: a unique name for the log file" >&2
	echo "    host: name or IP of the server" >&2
	echo "    port: TCP port to use" >&2
	echo "    command: an arbitrary command to run in a 1-second loop" >&2
	exit 1
}

[ $# -ge 3 ] || usage

NAME="$1"; shift
MODE="$1"; shift

case "$MODE" in
	ping)
		HOST="$1"; shift
		[ $# -eq 0 ] || usage
		;;
	server)
		PORT="$1"; shift
		[ $# -eq 0 ] || usage
		;;
	client)
		HOST="$1"; shift
		[ $# -eq 1 ] || usage
		PORT="$1"; shift
		[ $# -eq 0 ] || usage
		;;
	command)
		[ $# -ge 1 ] || usage
		COMMAND=$@
		;;
	*)
		usage
		;;
esac

LOG="$NAME.log"

###############################

datestr() {
	date '+%Y-%m-%d %H:%M:%S'
}

set +e
(
	while true; do
		case "$MODE" in
			ping)
				echo "Pinging $HOST"
				ping $HOST
				;;
			server)
				echo "Listening on port $PORT"
				nc -l $PORT
				;;
			client)
				echo "Contacting $HOST on $PORT"
				cat <(while true; do echo "client date: `datestr`"; sleep 1; done) | nc $HOST $PORT
				;;
			command)
				echo "Running: $COMMAND"
				$COMMAND
				;;
			*)
				echo "Getting here should be impossible" >&2
				exit 1
		esac

		echo "$MODE exited with code $?, restarting..."
		sleep 1
	done


) 2>&1 | while IFS= read -r line; do echo "[`datestr`] $line"; done | tee -a "$NAME.log" # https://unix.stackexchange.com/a/26729/223285

SUBSHELL_EXIT=$?
echo "Subshell exited with code $SUBSHELL_EXIT"

exit $SUBSHELL_EXIT


