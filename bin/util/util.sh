
### Handy functions ###

die() {
	local exitcode
	exitcode=$1; shift
	echo >&2 "...failed ($exitcode)! $@"
	exit ${exitcode}
}

tempname() {  # call like "MYVAR=`tempname`"
	mktemp /tmp/${0##*/}.XXXXXX || die -1
}

