#!/bin/sh

cd "`dirname "$0"`"

update() {
	if [ -f "$1/.git/authors" ]; then
		echo "Rebasing $1..."
		cd "$1"
		git svn rebase
		git push
		cd "../"
	else
		echo "'$1' is not a master SVN git repository!"
	fi
}

update "codeintel"
update "python-sitelib"
update "silvercity"
update "cElementTree"
update "elementtree"
update "inflector"
update "pcre"
update "scintilla"
update "sgmlop"
update "smallstuff"
