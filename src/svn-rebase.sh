#!/bin/sh
cd "`dirname "$0"`"
SRCDIR=`pwd`
ARG="$1"

check() {
	echo
	echo "********************************************************************************"
	echo "* $1"
	echo "* Press [enter] to continue [ctrl+c] to abort."
	echo "********************************************************************************"
	read
}

update() {
	REPO="$1"
	if [ -f "$REPO/.git/authors" ]; then
		echo "################################################################################"
		echo ">>> [svn] Rebasing SVN $REPO ..."
		cd "$REPO"

		# Switch to svn branch...
		git branch svn >/dev/null 2>&1
		git push -u origin svn >/dev/null 2>&1

		git co svn && \
		BEFORE=`git log --format="%H" | head -1`
		if [ "$ARG" = "--svn" ]; then
			git svn rebase || \
			check "Please check the SVN rebase!"
		fi
		AFTER=`git log --format="%H" | head -1`

		if [ "$BEFORE" != "$AFTER" ]; then
			echo ">>> [svn] Update! ($BEFORE vs. $AFTER)"
			SVN_UPDATED_DONE="YES"
		elif [ "$ARG" = "--force" ]; then
			echo ">>> [svn] Forced Update!"
			SVN_UPDATED_DONE="YES"
		else
			SVN_UPDATED_DONE="NO"
		fi

		if [ "$SVN_UPDATED_DONE" = "YES" ]; then
			# Commit changed
			git push -f

			echo
			echo "________________________________________________________________________________"
			echo ">>> [pep8] Apply PEP8 to SVN $REPO ..."
			git branch pep8 >/dev/null 2>&1
			git push -u origin pep8 >/dev/null 2>&1
			git co pep8 && \
			git reset --hard svn || \
			check "Cannot switch to pep8!"
			autopep8 -virj 4 .
			BEFORE=`git log --format="%H" | head -1`
			git commit -am "PEP 8 applied to SVN trunk"
			AFTER=`git log --format="%H" | head -1`
			if [ "$BEFORE" != "$AFTER" ]; then
				PEP8_DONE="YES"
			else
				PEP8_DONE="NO"
			fi
			git push -f

			echo
			echo "________________________________________________________________________________"
			echo ">>> [patched] Apply Patches over SVN of $REPO ..."
			git branch patched >/dev/null 2>&1
			git push -u origin patched >/dev/null 2>&1
			git co patched && \
			git reset --hard svn || \
			check "Cannot switch to patched!"

			# Apply patches here... (probably cannot be totally automated)
			if [ -d "../patches/$REPO" ]; then
				echo "Patching $REPO ..."
				# Some patches need to be ignored as they are already applied:
				# patches/scintilla/bug91001_markdown_inline_style.patch
				# patches/scintilla/bug92448_indicator_eof.patch
				find "../patches/$REPO" -type f -name "*.patch" \
					! -name "bug91001_markdown_inline_style.patch" \
					! -name "bug92448_indicator_eof.patch" \
					-print0 | sort -z | xargs -0 -I {} sh -c "echo {}; patch -sup0 < {}"
				find . \( -name '*.orig' -o -name "*.rej" \) -exec rm {} \;
				cd "../patches/$REPO"
					find . -type d -name '*' -mindepth 1 -exec sh -c 'echo mkdir -p $2; mkdir -p $2' -- "{}" "$SRCDIR/$REPO/{}" \;
					find . -type f -name '*' -mindepth 2 -exec sh -c 'echo cp $1 $2; rm -f $2; cp $1 $2' -- "{}" "$SRCDIR/$REPO/{}" \;
				cd "$SRCDIR/$REPO"
				git add -A
				check "Please confirm patches were correctly applied (and stash newly created files if needed)."
			fi

			BEFORE=`git log --format="%H" | head -1`
			git commit -am "OpenKomodo patches applied to SVN trunk"
			AFTER=`git log --format="%H" | head -1`
			if [ "$BEFORE" != "$AFTER" ]; then
				PATCHES_DONE="YES"
			else
				PATCHES_DONE="NO"
			fi
			git push -f

			echo
			echo "________________________________________________________________________________"
			if [ "$PATCHES_DONE" = "YES" ]; then
				echo ">>> [patched-pep8] Apply PEP8 to patched branch of $REPO ..."
				git branch patched-pep8 >/dev/null 2>&1
				git push -u origin patched-pep8 >/dev/null 2>&1
				git co patched-pep8 && \
				OLD_PATCHED_PEP8=`git log --format="%H" | head -1` && \
				git reset --hard patched || \
				check "Cannot switch to patched-pep8!"
				autopep8 -virj 4 . || \
				check "Cannot autopep8!"
				git commit -am "PEP 8 applied to SVN trunk + OpenKomodo patches"
				git push -f
			else
				if [ "$PEP8_DONE" = "YES" ]; then
					echo ">>> [patched-pep8] Use PEP8 as the PEP8 patched branch of $REPO ..."
				else
					echo ">>> [patched-pep8] Use SVN as the PEP8 patched branch of $REPO ..."
				fi
				git branch patched-pep8 >/dev/null 2>&1
				git push -u origin patched-pep8 >/dev/null 2>&1
				git co patched-pep8 && \
				OLD_PATCHED_PEP8=`git log --format="%H" | head -1` && \
				git reset --hard pep8 || \
				check "Cannot switch to patched-pep8!"
				if [ "$PEP8_DONE" = "YES" ]; then
					git commit --amend -m "PEP 8 applied to SVN trunk + OpenKomodo patches"
				fi
				git push -f
			fi

			echo
			echo "________________________________________________________________________________"
			echo ">>> [master] Rebasing master of $REPO ..."
			git co master && \
			git rebase --onto patched-pep8 $OLD_PATCHED_PEP8 master || \
			check "Please check the rebase!"
			git push -f

			echo
			echo "________________________________________________________________________________"
			echo ">>> [py3] Making py3 branch (Base 2to3's Python3 compatible branch) of $REPO ..."
			git branch py3 >/dev/null 2>&1
			git push -u origin py3 >/dev/null 2>&1
			git co py3 && \
			OLD_PY3=`git log --format="%H" | head -1` && \
			git reset --hard master || \
			check "Cannot switch to py3!"
			2to3 --no-diffs -nwj4 . || \
			check "Cannot 2to3!"
			# python-modernize --compat-unicode --no-diffs -nwj 4 .
			git commit -am "Python3 support (using 2to3)"
			git push -f

			echo
			echo "________________________________________________________________________________"
			echo ">>> [development] Rebasing development (python3 compatible branch) of $REPO ..."
			git branch development >/dev/null 2>&1
			git push -u origin development >/dev/null 2>&1
			git co development && \
			git rebase --onto py3 $OLD_PY3 development || \
			check "Please check the rebase!"
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

update "patches"
update "python-sitelib"
update "silvercity"
update "cElementTree"
update "ciElementTree"
update "elementtree"
update "inflector"
update "pcre"
update "scintilla"
update "sgmlop"
update "smallstuff"
update "udl"
update "codeintel"
