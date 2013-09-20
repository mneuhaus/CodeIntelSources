#!/usr/bin/env bash
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

get_branch() {
	git branch 2> /dev/null | sed -n -e 's/^\* \(.*\)/\1/p'
}

GIT_BRANCH="$(get_branch)"

if [ "${OSTYPE:0:5}" = "linux" ]; then
	# In Linux, Sublime Text's Python is compiled with UCS4:
	echo "SublimeCodeIntel for Linux"
	echo "=========================="
	BUILDDIR="$SRCDIR/build/${GIT_BRANCH:-unknown}"
	PYTHON="${PYTHON:-python}"
	if [ -z $ARCH ]; then
		ARCH=`uname -m`
	fi
	if [ "$ARCH" = "x86_64" ]; then
		export CC="gcc -m64"
		export CXX="g++ -m64"
		export CFLAGS="-fno-stack-protector -fPIC -DPy_UNICODE_SIZE=4 -I $BUILDDIR/pcre"
		export CXXFLAGS="-fno-stack-protector -fPIC -DPy_UNICODE_SIZE=4 -I $BUILDDIR/pcre"
		export LDFLAGS="-static-libstdc++ -static-libgcc"
		ARCH="linux_libcpp6_x86_64"
	else
		export CC="gcc -m32"
		export CXX="g++ -m32"
		export CFLAGS="-fno-stack-protector -DPy_UNICODE_SIZE=4 -I $BUILDDIR/pcre"
		export CXXFLAGS="-fno-stack-protector -DPy_UNICODE_SIZE=4 -I $BUILDDIR/pcre"
		export LDFLAGS="-static-libstdc++ -static-libgcc"
		ARCH="linux_libcpp6_x86"
	fi
	LIBPCRE="$BUILDDIR/pcre/.libs/libpcre.a"
	LIBPCRE_H="$BUILDDIR/pcre/pcre.h"
	SO="so"
elif [ "${OSTYPE:0:6}" = "darwin" ]; then
	echo "SublimeCodeIntel for Mac OS X"
	echo "============================="
	BUILDDIR="$SRCDIR/build/${GIT_BRANCH:-unknown}"
	PYTHON="${PYTHON:-python}"
	export ARCHFLAGS="-arch i386 -arch x86_64"
	export CFLAGS="-arch i386 -arch x86_64 -I $BUILDDIR/pcre -mmacosx-version-min=10.6"
	export CXXFLAGS="-arch i386 -arch x86_64 -I $BUILDDIR/pcre -mmacosx-version-min=10.6"
	export LDFLAGS="-arch i386 -arch x86_64"
	ARCH="macosx_universal"
	LIBPCRE="$BUILDDIR/pcre/.libs/libpcre.a"
	LIBPCRE_H="$BUILDDIR/pcre/pcre.h"
	SO="so"
else
	if [[ "$FRAMEWORKDIR" = *"Framework64"* ]]; then
		echo "SublimeCodeIntel for Windows (amd64)"
		echo "===================================="
		BUILDDIR="$SRCDIR/build/${GIT_BRANCH:-unknown}"
		PYTHON="${PYTHON:-C:/Python26-x64/python.exe}"
		ARCH="win64"
	else
		echo "SublimeCodeIntel for Windows (x86)"
		echo "=================================="
		BUILDDIR="$SRCDIR/build/${GIT_BRANCH:-unknown}"
		PYTHON="${PYTHON:-C:/Python26/python.exe}"
		ARCH="win32"
	fi
	ERR=" (You need to have Visual Studio and run this script from the Command Prompt. You also need the following tools: bash, patch, find and python 2.6 available from the command line.)"
	if [ ! -f "$PYTHON" ]; then
		ERR="$ERR Python must exist at $PYTHON"
		PYTHON="${PYTHON:-python}"
	fi
	export CFLAGS="-I $BUILDDIR/pcre $CFLAGS"
	export CXXFLAGS="-I $BUILDDIR/pcre $CXXFLAGS"
	LIBPCRE="$BUILDDIR/pcre/libpcre.lib"
	LIBPCRE_H="$BUILDDIR/pcre/pcre.h"
	OSTYPE=""
	SO="pyd"
fi
LOGDIR="$BUILDDIR/logs"

get_pyver() {
	$PYTHON -c "import sys; sys.stdout.write('%s.%s' % sys.version_info[:2])" 2> /dev/null
}

PYVER="$(get_pyver)"
ARCHDIR="_${ARCH}_py${PYVER//./}"

if [ "$ARG" != "--dist" ]; then
	ARCHDIR="_local_arch"
fi

DEPLOYMENTDIR="$SRCDIR/../SublimeCodeIntel"

checkout() {
	cd "$SRCDIR" && ([ "$GIT_BRANCH" = "" ] || [ "$GIT_BRANCH" = "$(get_branch)" ] || (echo "src:" && git checkout "$GIT_BRANCH")) && \
	cd "$SRCDIR/pcre" && ([ "$GIT_BRANCH" = "" ] || [ "$GIT_BRANCH" = "$(get_branch)" ] || (echo "pcre:" && git checkout "$GIT_BRANCH")) && \
	cd "$SRCDIR/scintilla" && ([ "$GIT_BRANCH" = "" ] || [ "$GIT_BRANCH" = "$(get_branch)" ] || (echo "scintilla:" && git checkout "$GIT_BRANCH")) && \
	cd "$SRCDIR/silvercity" && ([ "$GIT_BRANCH" = "" ] || [ "$GIT_BRANCH" = "$(get_branch)" ] || (echo "silvercity:" && git checkout "$GIT_BRANCH")) && \
	cd "$SRCDIR/cElementTree" && ([ "$GIT_BRANCH" = "" ] || [ "$GIT_BRANCH" = "$(get_branch)" ] || (echo "cElementTree:" && git checkout "$GIT_BRANCH")) && \
	cd "$SRCDIR/ciElementTree" && ([ "$GIT_BRANCH" = "" ] || [ "$GIT_BRANCH" = "$(get_branch)" ] || (echo "ciElementTree:" && git checkout "$GIT_BRANCH")) && \
	cd "$SRCDIR/iElementTree" && ([ "master" = "" ] || [ "master" = "$(get_branch)" ] || (echo "iElementTree:" && git checkout "master")) && \
	cd "$SRCDIR/sgmlop" && ([ "$GIT_BRANCH" = "" ] || [ "$GIT_BRANCH" = "$(get_branch)" ] || (echo "sgmlop:" && git checkout "$GIT_BRANCH")) && \
	cd "$SRCDIR/udl" && ([ "$GIT_BRANCH" = "" ] || [ "$GIT_BRANCH" = "$(get_branch)" ] || (echo "udl:" && git checkout "$GIT_BRANCH")) && \
		\
	cd "$SRCDIR/codeintel" && ([ "$GIT_BRANCH" = "" ] || [ "$GIT_BRANCH" = "$(get_branch)" ] || (echo "codeintel:" && git checkout "$GIT_BRANCH")) && \
	cd "$SRCDIR/smallstuff" && ([ "$GIT_BRANCH" = "" ] || [ "$GIT_BRANCH" = "$(get_branch)" ] || (echo "smallstuff:" && git checkout "$GIT_BRANCH")) && \
	cd "$SRCDIR/python-sitelib" && ([ "$GIT_BRANCH" = "" ] || [ "$GIT_BRANCH" = "$(get_branch)" ] || (echo "python-sitelib:" && git checkout "$GIT_BRANCH")) && \
	cd "$SRCDIR/elementtree" && ([ "$GIT_BRANCH" = "" ] || [ "$GIT_BRANCH" = "$(get_branch)" ] || (echo "elementtree:" && git checkout "$GIT_BRANCH")) && \
	cd "$SRCDIR/inflector" && ([ "$GIT_BRANCH" = "" ] || [ "$GIT_BRANCH" = "$(get_branch)" ] || (echo "inflector:" && git checkout "$GIT_BRANCH")) && \
	cd "$DEPLOYMENTDIR" && ([ "$GIT_BRANCH" = "" ] || [ "$GIT_BRANCH" = "$(get_branch)" ] || (echo "SublimeCodeIntel:" && git checkout "$GIT_BRANCH")) && \
		\
	cd "$SRCDIR/chardet" && ([ "master" = "" ] || [ "master" = "$(get_branch)" ] || (echo "chardet:" && git checkout "master")) && \
	cd "$SRCDIR/python3-chardet" && ([ "master" = "" ] || [ "master" = "$(get_branch)" ] || (echo "python3-chardet:" && git checkout "master")) && \
	cd "$SRCDIR/zope.cachedescriptors" && ([ "master" = "" ] || [ "master" = "$(get_branch)" ] || (echo "zope.cachedescriptors:" && git checkout "master"))
}

reset_hard() {
	checkout && \
	check "Please check the modules have been checked out! (Ready to do: git reset --hard)" && \
	cd "$SRCDIR" && echo "src: (git reset --hard origin/$GIT_BRANCH)" && git fetch && git reset --hard "origin/$GIT_BRANCH" && \
	cd "$SRCDIR/pcre" && echo "pcre: (git reset --hard origin/$GIT_BRANCH)" && git fetch && git reset --hard "origin/$GIT_BRANCH" && \
	cd "$SRCDIR/scintilla" && echo "scintilla: (git reset --hard origin/$GIT_BRANCH)" && git fetch && git reset --hard "origin/$GIT_BRANCH" && \
	cd "$SRCDIR/silvercity" && echo "silvercity: (git reset --hard origin/$GIT_BRANCH)" && git fetch && git reset --hard "origin/$GIT_BRANCH" && \
	cd "$SRCDIR/cElementTree" && echo "cElementTree: (git reset --hard origin/$GIT_BRANCH)" && git fetch && git reset --hard "origin/$GIT_BRANCH" && \
	cd "$SRCDIR/ciElementTree" && echo "ciElementTree: (git reset --hard origin/$GIT_BRANCH)" && git fetch && git reset --hard "origin/$GIT_BRANCH" && \
	cd "$SRCDIR/iElementTree" && echo "iElementTree: (git reset --hard origin/master)" && git fetch && git reset --hard "origin/master" && \
	cd "$SRCDIR/sgmlop" && echo "sgmlop: (git reset --hard origin/$GIT_BRANCH)" && git fetch && git reset --hard "origin/$GIT_BRANCH" && \
	cd "$SRCDIR/udl" && echo "udl: (git reset --hard origin/$GIT_BRANCH)" && git fetch && git reset --hard "origin/$GIT_BRANCH" && \
		\
	cd "$SRCDIR/codeintel" && echo "codeintel: (git reset --hard origin/$GIT_BRANCH)" && git fetch && git reset --hard "origin/$GIT_BRANCH" && \
	cd "$SRCDIR/smallstuff" && echo "smallstuff: (git reset --hard origin/$GIT_BRANCH)" && git fetch && git reset --hard "origin/$GIT_BRANCH" && \
	cd "$SRCDIR/python-sitelib" && echo "python-sitelib: (git reset --hard origin/$GIT_BRANCH)" && git fetch && git reset --hard "origin/$GIT_BRANCH" && \
	cd "$SRCDIR/elementtree" && echo "elementtree: (git reset --hard origin/$GIT_BRANCH)" && git fetch && git reset --hard "origin/$GIT_BRANCH" && \
	cd "$SRCDIR/inflector" && echo "inflector: (git reset --hard origin/$GIT_BRANCH)" && git fetch && git reset --hard "origin/$GIT_BRANCH" && \
	cd "$DEPLOYMENTDIR" && echo "SublimeCodeIntel: (git reset --hard origin/$GIT_BRANCH)" && git fetch && git reset --hard "origin/$GIT_BRANCH" && \
		\
	cd "$SRCDIR/chardet" && echo "chardet: (git reset --hard origin/master)" && git fetch && git reset --hard "origin/master" && \
	cd "$SRCDIR/python3-chardet" && echo "python3-chardet: (git reset --hard origin/master)" && git fetch && git reset --hard "origin/master" && \
	cd "$SRCDIR/zope.cachedescriptors" && echo "zope.cachedescriptors: (git reset --hard origin/master)" && git fetch && git reset --hard "origin/master"
}

build() {
	if [ "$ARG" = "--force" ]; then
		rm -rf "$BUILDDIR"
		rm -rf "$LOGDIR"
	fi
	mkdir -p "$LOGDIR"
	touch "$LOGDIR/PCRE.log"
	touch "$LOGDIR/Sgmlop.log"
	touch "$LOGDIR/Scintilla.log"
	touch "$LOGDIR/SilverCity.log"
	touch "$LOGDIR/cElementTree.log"
	touch "$LOGDIR/ciElementTree.log"
	touch "$LOGDIR/iElementTree.log"

	echo "Building [$ARCH, python v$PYVER] (${GIT_BRANCH:-unknown} branch)..." && \
	checkout && \
	( \
		([ "$OSTYPE" != "" ] && echo "Building PCRE (*nix)..." && \
			([ -d "$BUILDDIR/pcre" ] || (
				rm -rf "$BUILDDIR/pcre" && \
				cp -R "$SRCDIR/pcre" "$BUILDDIR/pcre" && \
				cd "$BUILDDIR/pcre" && \
					mkdir .libs && \
					./configure --disable-shared --disable-dependency-tracking --enable-utf8 --enable-unicode-properties > "$LOGDIR/PCRE.log" 2>&1 \
			)) && \
			cd "$BUILDDIR/pcre" && \
				make >> "$LOGDIR/PCRE.log" 2>&1 && \
			cd "$SRCDIR"
		) || \
			\
		([ "$OSTYPE" = "" ] && echo "Building PCRE (win)..." && \
			([ -d "$BUILDDIR/pcre" ] || (
				rm -rf "$BUILDDIR/pcre" && \
				cp -R "$SRCDIR/pcre" "$BUILDDIR/pcre" && \
				cd "$BUILDDIR/pcre" && \
					cp "Win32/pcre.h" "pcre.h" && \
					cp "Win32/config.h" "config.h" && \
					echo "#undef HAVE_DIRENT_H" >> config.h && \
					echo "#undef HAVE_INTTYPES_H" >> config.h && \
					echo "#undef HAVE_STDINT_H" >> config.h && \
					echo "#undef HAVE_UNISTD_H" >> config.h && \
					echo "#define HAVE_WINDOWS_H 1" >> config.h && \
					echo "#define SUPPORT_UCP" >> config.h && \
					echo "#define SUPPORT_UTF8" >> config.h \
			)) && \
			cd "$BUILDDIR/pcre" && \
				nmake -f $SRCDIR/winpcre.mak clean libpcre.lib >> "$LOGDIR/PCRE.log" 2>&1 && \
			cd "$SRCDIR"
		) \
	) && \
		\
	(echo "Patching Scintilla..." && \
		([ -d "$BUILDDIR/scintilla" ] || (
			rm -rf "$BUILDDIR/scintilla" && \
			cp -R "$SRCDIR/scintilla" "$BUILDDIR/scintilla" \
		)) && \
		cd "$BUILDDIR/scintilla" && \
			cd include && \
				$PYTHON HFacer.py > "$LOGDIR/Scintilla.log" 2>&1
	) && \
		\
	(echo "Building SilverCity..." && \
		([ -d "$BUILDDIR/silvercity" ] || (
			rm -rf "$BUILDDIR/silvercity" && \
			cp -R "$SRCDIR/silvercity" "$BUILDDIR/silvercity" \
		)) && \
		cd "$BUILDDIR/silvercity" && \
			cp -f "$LIBPCRE" . && \
			cp -f "$LIBPCRE_H" "../scintilla/include/" && \
			cd PySilverCity/Src && \
				$PYTHON write_scintilla.py \
					../../../scintilla/include/ \
					../../../scintilla/include/Scintilla.iface \
					../SilverCity/ScintillaConstants.py > "$LOGDIR/SilverCity.log" 2>&1 && \
			cd ../.. && \
			$PYTHON setup.py build >> "$LOGDIR/SilverCity.log" 2>&1
	) && \
		\
	( \
		([ "${PYVER:0:1}" = "2" ] && ( \
			(echo "Building cElementTree..." && \
				([ -d "$BUILDDIR/cElementTree" ] || (
					rm -rf "$BUILDDIR/cElementTree" && \
					cp -R "$SRCDIR/cElementTree" "$BUILDDIR/cElementTree" \
				)) && \
				cd "$BUILDDIR/cElementTree" && \
					$PYTHON setup.py build > "$LOGDIR/cElementTree.log" 2>&1
			) && \
			(echo "Building ciElementTree..." && \
				([ -d "$BUILDDIR/ciElementTree" ] || (
					rm -rf "$BUILDDIR/ciElementTree" && \
					cp -R "$SRCDIR/ciElementTree" "$BUILDDIR/ciElementTree" \
				)) && \
				cd "$BUILDDIR/ciElementTree" && \
					$PYTHON setup.py build > "$LOGDIR/ciElementTree.log" 2>&1
			) \
		)) || \
		([ "${PYVER:0:1}" = "3" ] && ( \
			(echo "Building iElementTree..." && \
				([ -d "$BUILDDIR/iElementTree" ] || (
					rm -rf "$BUILDDIR/iElementTree" && \
					cp -R "$SRCDIR/iElementTree" "$BUILDDIR/iElementTree" \
				)) && \
				cd "$BUILDDIR/iElementTree" && \
					$PYTHON setup.py build > "$LOGDIR/iElementTree.log" 2>&1
			) \
		)) \
	) && \
		\
	(echo "Building Sgmlop..." && \
		([ -d "$BUILDDIR/sgmlop" ] || (
			rm -rf "$BUILDDIR/sgmlop" && \
			cp -R "$SRCDIR/sgmlop" "$BUILDDIR/sgmlop" \
		)) && \
		cd "$BUILDDIR/sgmlop" && \
			$PYTHON setup.py build > "$LOGDIR/Sgmlop.log" 2>&1
	) && \
		\
	(echo "Building UDL lexers..." && \
		([ -d "$BUILDDIR/udl" ] || (
			rm -rf "$BUILDDIR/udl" && \
			cp -R "$SRCDIR/udl" "$BUILDDIR/udl" \
		)) && \
		cd "$BUILDDIR/udl" && \
			cp "$SRCDIR/more4sublime/chromereg.py" . && \
			find udl -type f -name '*-mainlex.udl' -exec $PYTHON luddite.py just_compile "{}" \; > "$LOGDIR/UDL.log" 2>&1
	) && \
		\
	cd $SRCDIR && \
		\
	echo "Build Done!" || \
	echo "Build Failed!$ERR"

	if [ "$OSTYPE" != "" ]; then
		find "build" -type f -name "*.$SO" -exec strip "{}" \; > /dev/null 2>&1
		find "build" -type f -name "*.$SO" -exec strip -S "{}" \; > /dev/null 2>&1
	fi
}

if [ ! $DEPLOYING ]; then
	build
fi
