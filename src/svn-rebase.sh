#!/bin/sh

cd "`dirname "$0"`"

update() {
	if [ -f "$1/.git/authors" ]; then
		echo "################################################################################"
		echo ">>> Rebasing SVN $1..."
		cd "$1"

		# Switch to svn branch...
		git branch svn >/dev/null 2>&1
		git push -u origin svn >/dev/null 2>&1
		git co svn

		BEFORE=`git log | head -1`
		git svn rebase
		AFTER=`git log | head -1`
		if [ "$BEFORE" != "$AFTER" ]; then
			SVN_UPDATED_DONE="YES"
		else
			SVN_UPDATED_DONE="NO"
		fi

		if [ "$SVN_UPDATED_DONE" = "YES" ]; then
			# Commit changed
			git push

			echo
			echo "________________________________________________________________________________"
			echo ">>> Apply PEP8 to SVN $1..."
			git branch pep8 >/dev/null 2>&1
			git push -u origin pep8 >/dev/null 2>&1
			git co pep8
			git reset --hard svn
			autopep8 -virj 4 .
			BEFORE=`git log | head -1`
			git commit -am "PEP 8 applied to SVN trunk"
			AFTER=`git log | head -1`
			if [ "$BEFORE" != "$AFTER" ]; then
				PEP8_DONE="YES"
			else
				PEP8_DONE="NO"
			fi
			git push -f

			echo
			echo "________________________________________________________________________________"
			echo ">>> Apply Patches over SVN of $1..."
			git branch patched >/dev/null 2>&1
			git push -u origin patched >/dev/null 2>&1
			git co patched
			git reset --hard svn

			echo
			echo "********************************************************************************"
			echo "*                                                                              *"
			echo "*  Please apply patches and then press [ENTER] to continue (ctrl+c to abort)   *"
			echo "*                                                                              *"
			echo "********************************************************************************"
			read
			# Apply patches here... (probably cannot be automated)

			BEFORE=`git log | head -1`
			git commit -am "OpenKomodo patches applied to SVN trunk"
			AFTER=`git log | head -1`
			if [ "$BEFORE" != "$AFTER" ]; then
				PATCHES_DONE="YES"
			else
				PATCHES_DONE="NO"
			fi
			git push -f

			echo
			echo "________________________________________________________________________________"
			if [ "$PATCHES_DONE" = "YES" ]; then
				echo ">>> Apply PEP8 to patched branch of $1..."
				git branch patched-pep8 >/dev/null 2>&1
				git push -u origin patched-pep8 >/dev/null 2>&1
				git co patched-pep8
				git reset --hard patched
				autopep8 -virj 4 .
				git commit -am "PEP 8 applied to SVN trunk + OpenKomodo patches"
				git push -f
			else
				if [ "$PEP8_DONE" = "YES" ]; then
					echo ">>> Use PEP8 as the PEP8 patched branch of $1..."
				else
					echo ">>> Use SVN as the PEP8 patched branch of $1..."
				fi
				git branch patched-pep8 >/dev/null 2>&1
				git push -u origin patched-pep8 >/dev/null 2>&1
				git co patched-pep8
				git reset --hard pep8
				if [ "$PEP8_DONE" = "YES" ]; then
					git commit --amend -m "PEP 8 applied to SVN trunk + OpenKomodo patches"
				fi
				git push -f
			fi

			echo
			echo "________________________________________________________________________________"
			echo ">>> Rebasing master of $1..."
			git co master
			git rebase patched-pep8
			git push -f

			echo
			echo "________________________________________________________________________________"
			echo ">>> Making Python3 compatible branch of $1..."
			git branch py3 >/dev/null 2>&1
			git push -u origin py3 >/dev/null 2>&1
			git co py3
			git reset --hard master
			python-modernize --compat-unicode --no-diffs -nwj 4 .
			git commit -am "Python2 and Python3 support (using python-modernize's 2to3)..."
			git push -f
		fi

		# Switch to desired branch:
		git co master
		echo "$1 done!"
		echo

		cd "../"
	else
		echo ">>> '$1' is not a master SVN git repository!"
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
update "patches"
update "udl"
