#!/usr/bin/env bash

set -e
set -o pipefail

usage() {
	echo "usage:" >&2
	echo "  $0 ping <host>" >&2
	echo "  $0 server <port>" >&2
	echo "  $0 client <host> <port>" >&2
	echo "  $0 command <command> [...]" >&2
	echo "" >&2
	echo "    host: name or IP of the server" >&2
	echo "    port: TCP port to use" >&2
	echo "    command: an arbitrary command to run in a 1-second loop" >&2
	exit 1
}

[ $# -ge 2 ] || usage

MODE="$1"; shift

case "$MODE" in
	ping)
		HOST="$1"; shift
		[ $# -eq 0 ] || usage
		LOG="ping_$HOST.log"
		;;
	server)
		PORT="$1"; shift
		[ $# -eq 0 ] || usage
		LOG="server_$PORT.log"
		;;
	client)
		HOST="$1"; shift
		[ $# -eq 1 ] || usage
		PORT="$1"; shift
		[ $# -eq 0 ] || usage
		LOG="client_${HOST}_$PORT.log"
		;;
	command)
		[ $# -ge 1 ] || usage
		COMMAND=$@
		LOG="command_$1.log"
		;;
	*)
		usage
		;;
esac

if echo `uname` | grep -E ^MINGW > /dev/null ; then
	NC=./nc.exe
else
	NC=nc
fi

###############################

datestr() {
	date '+%Y-%m-%d %H:%M:%S'
}

tee_compressed() {  # https://stackoverflow.com/a/11454477/1132502
	while read LINE ; do
		if echo `uname` | grep -E ^MINGW > /dev/null ; then
			echo $LINE | tee -a "$LOG"
		else
			echo $LINE | tee >(bzip2 -c >> "$LOG.bz2")
		fi
	done
}

set +e
(
	while true; do
		case "$MODE" in
			ping)
				echo "Pinging $HOST"
				if echo `uname` | grep -E ^Darwin > /dev/null ; then
					ping $HOST | grep --line-buffered -v "64 bytes"
				elif echo `uname` | grep -E ^MINGW > /dev/null ; then
					ping -t -w 1000 $HOST | grep --line-buffered -v bytes=32
				else # linux, presumably
					ping -O -q $HOST
				fi
				;;
			server)
				echo "Listening on port $PORT"
				$NC -l $PORT
				;;
			client)
				echo "Contacting $HOST on $PORT"
				cat <(while true; do echo "client date: `datestr`"; sleep 1; done) | $NC $HOST $PORT
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


) 2>&1 | while IFS= read -r line; do echo "[`datestr`] $line"; done | tee_compressed  # https://unix.stackexchange.com/a/26729/223285

SUBSHELL_EXIT=$?
echo "Subshell exited with code $SUBSHELL_EXIT"

exit $SUBSHELL_EXIT


