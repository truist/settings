#!/bin/sh

set -eu

. ~/bin/util/util.sh

PKG_LIST=/etc/pkglist
test -f $PKG_LIST

PKGSRC_PATH=/var/pkg_comp/pkgsrc
test -d $PKGSRC_PATH

PACKAGES_PATH=/var/pkg_comp/packages/All
test -d $PACKAGES_PATH

PKGIN=/usr/pkg/bin/pkgin
test -x $PKGIN


desired_raw() {
	grep -v '^#' "$PKG_LIST" | sort
}

_DESIRED_PACKAGE_NAME_CACHE=
_uncached_desired_package_name() {
	DRTEMP="`tempname`"
	for p in `desired_raw`; do
		cd "$PKGSRC_PATH/$p" || die $?
		make show-var VARNAME=PKGNAME || die $?
	done > "$DRTEMP" || die $?
	cat "$DRTEMP" | sort
}
desired_package_names() {
	if [ -z "$_DESIRED_PACKAGE_NAME_CACHE" ]; then
		_DESIRED_PACKAGE_NAME_CACHE="`_uncached_desired_package_name`"
	fi
	echo "$_DESIRED_PACKAGE_NAME_CACHE"
}

current_keep() {
	$PKGIN export | grep -v 'devel/bmake' | grep -v 'pkgtools/bootstrap-mk-files' | grep -v 'pkgtools/cwrappers' | grep -v 'pkgtools/pkg_install' | sort
}

current_installed() {
	DESIRED="`desired_package_names`"
	$PKGIN list | cut -d ' ' -f 1 | grep -F "$DESIRED" | sort
}

current_available() {
	DESIRED="`desired_package_names`"
	$PKGIN avail | cut -d ' ' -f 1 | grep -F "$DESIRED" | sort
}

current_package_files() {
	DESIRED="`desired_package_names`"
	ls "$PACKAGES_PATH/"*.tgz | xargs -I % -n 1 basename % .tgz | grep -F "$DESIRED" | sort
}

_do_diff() {
	T1=`tempname`
	T2=`tempname`
	$1 > "$T1"
	$2 > "$T2"
	diff "$T1" "$T2"
}

diff_desired_keep() {
	_do_diff 'desired_raw' 'current_keep'
}

diff_desired_installed() {
	_do_diff 'desired_package_names' 'current_installed'
}

diff_installed_available() {
	_do_diff 'current_installed' 'current_available'
}

diff_available_files() {
	_do_diff 'current_available' 'current_package_files'
}

pkg_comp_hygiene() {
	echo "PKG_COMP HYGIENE REPORT"
	echo "-----------------------"
	echo ""
	echo "Desired packages:"
	desired_raw
	echo ""
	echo "Diff against 'keep' list:"
	diff_desired_keep
	echo ""
	echo "Diff against installed list:"
	diff_desired_installed
	echo ""
	echo "Diff installed against available:"
	diff_installed_available
	echo ""
	echo "Diff available against actual packages:"
	diff_available_files
	echo ""
	echo "Done!"
}

