#!/bin/sh

# exit the script on first error
set -e

# args and help
if [ "$#" -lt 3 ] || [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; then
	cat <<END >&2
args: <primary_repo_relative_path> <secondary_repo_relative_path> <secondary_repo_branch> [<new_subdir_name>]

This script will:
 - fetch the <secondary_repo_branch> from <secondary_repo_relative_path>
   into <primary_repo_relative_path> in a new branch
 - optionally rewrite the paths from the secondary repo to appear as if
   they were always in <new_subdir_name>
 - merge the new branch into <primary_repo_relative_path>'s current branch
END

	exit 1
fi
PRIMARY=$1
SECONDARY=$2
SECONDARY_BRANCH=$3
NEWSUBDIR=$4

STARTDIR=`pwd`
NEWBRANCH=`basename $SECONDARY`

cd $PRIMARY
git fetch $STARTDIR/$SECONDARY $SECONDARY_BRANCH:$NEWBRANCH

if [ -n "$NEWSUBDIR" ]; then
	git filter-branch --index-filter '
		git ls-files -s |
		sed "s,\t,&'"$NEWSUBDIR"'/," |
		GIT_INDEX_FILE=$GIT_INDEX_FILE.new git update-index --index-info &&
		mv $GIT_INDEX_FILE.new $GIT_INDEX_FILE
	' $NEWBRANCH
fi

git merge $NEWBRANCH

