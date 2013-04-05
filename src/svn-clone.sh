#!/bin/sh

cd "`dirname "$0"`/../"

################################################################################
# Clone needed stuff for CodeIntel:

project_clone() {
	if [ ! -d "src/$1" ]; then
		echo "Cloning $1 from SVN..."
		git svn clone -A "src/authors" "http://svn.openkomodo.com/repos/openkomodo/trunk/$2" "src/$1"
		echo "Setting $1 as a master SVN git repository..."
		cp "src/authors" "src/$1/.git/authors"
		sed -i "" 's@authorsfile = .*@authorsfile = .git/authors@' "src/$1/.git/config"
		git submodule add "git://github.com/SublimeCodeIntel/$1.git" "src/$1"
		cd "src/$1"
		git remote add origin "git@github.com:SublimeCodeIntel/$1.git"
		git push -u origin master
		cd "../../"
	fi
}
project_clone "codeintel" "src/codeintel"
project_clone "python-sitelib" "src/python-sitelib"
project_clone "silvercity" "src/silvercity"
project_clone "cElementTree" "contrib/cElementTree"
project_clone "elementtree" "contrib/elementtree"
project_clone "inflector" "contrib/inflector"
project_clone "pcre" "contrib/pcre"
project_clone "scintilla" "contrib/scintilla"
project_clone "sgmlop" "contrib/sgmlop"
project_clone "smallstuff" "contrib/smallstuff"

################################################################################
# Clone full openkomodo and addons repositories (only if needed):

# full_clone() {
# 	if [ ! -d "addons" ]; then
# 		echo "Cloning $1 from SVN..."
# 		git svn clone -A "src/authors" "http://svn.openkomodo.com/repos/addons" "src/addons"
# 	fi
# 	if [ ! -d "openkomodo" ]; then
# 		echo "Cloning $1 from SVN..."
# 		git svn clone -A "src/authors" -s "http://svn.openkomodo.com/repos/openkomodo" "src/openkomodo"
# 	fi
# }
# full_clone
