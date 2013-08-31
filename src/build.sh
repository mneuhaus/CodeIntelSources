#!/usr/bin/env bash
cd "`dirname "$0"`"
SRCDIR=`pwd`
ARG="$1"

GIT_BRANCH="$(git branch 2> /dev/null | sed -n -e 's/^\* \(.*\)/\1/p')"

if [ $OSTYPE = "linux-gnu" ]; then
	# In Linux, Sublime Text's Python is compiled with UCS4:
	echo "SublimeCodeIntel for Linux"
	echo "=========================="
	BUILDDIR="$SRCDIR/build/${GIT_BRANCH:-unknown}"
	PYTHON="python"
	if [ `uname -m` = "x86_64" ]; then
		export CXXFLAGS="-fno-stack-protector -fPIC -DPy_UNICODE_SIZE=4 -I $BUILDDIR/pcre"
		export CFLAGS="-fno-stack-protector -fPIC -DPy_UNICODE_SIZE=4 -I $BUILDDIR/pcre"
	else
		export CXXFLAGS="-fno-stack-protector -DPy_UNICODE_SIZE=4 -I $BUILDDIR/pcre"
		export CFLAGS="-fno-stack-protector -DPy_UNICODE_SIZE=4 -I $BUILDDIR/pcre"
	fi
	LIBPCRE="$BUILDDIR/pcre/.libs/libpcre.a"
	SO="so"
elif [ ${OSTYPE:0:6} = "darwin" ]; then
	echo "SublimeCodeIntel for Mac OS X"
	echo "============================="
	BUILDDIR="$SRCDIR/build/${GIT_BRANCH:-unknown}"
	PYTHON="python"
	export ARCHFLAGS="-arch i386 -arch x86_64"
	export CXXFLAGS="-arch i386 -arch x86_64 -I $BUILDDIR/pcre"
	export CFLAGS="-arch i386 -arch x86_64 -I $BUILDDIR/pcre"
	export LDFLAGS="-arch i386 -arch x86_64"
	LIBPCRE="$BUILDDIR/pcre/.libs/libpcre.a"
	SO="so"
else
	if [[ "$FRAMEWORKDIR" = *"Framework64"* ]]; then
		echo "SublimeCodeIntel for Windows (amd64)"
		echo "===================================="
		BUILDDIR="$SRCDIR/build/${GIT_BRANCH:-unknown}"
		PYTHON="C:/Python26-x64/python.exe"
	else
		echo "SublimeCodeIntel for Windows (x86)"
		echo "=================================="
		BUILDDIR="$SRCDIR/build/${GIT_BRANCH:-unknown}"
		PYTHON="C:/Python26/python.exe"
	fi
	ERR=" (You need to have Visual Studio and run this script from the Command Prompt. You also need the following tools: bash, patch, find and python 2.6 available from the command line.)"
	if [ ! -f "$PYTHON" ]; then
		ERR="$ERR Python must exist at $PYTHON"
		PYTHON="python"
	fi
	export CXXFLAGS="-I $BUILDDIR/pcre $CXXFLAGS"
	export CFLAGS="-I $BUILDDIR/pcre $CFLAGS"
	LIBPCRE="$BUILDDIR/pcre/libpcre.lib"
	OSTYPE=""
	SO="pyd"
fi
LOGDIR="$BUILDDIR/logs"

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

	echo "Building (${GIT_BRANCH:-unknown} branch)..." && \
	([ "$GIT_BRANCH" = "" ] || git checkout "$GIT_BRANCH") && \
	( \
		([ "$OSTYPE" != "" ] && echo "Building PCRE (*nix)..." && \
			([ -d "$BUILDDIR/pcre" ] || (
				([ "$GIT_BRANCH" = "" ] || cd "$SRCDIR/pcre" && git checkout "$GIT_BRANCH") && \
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
				([ "$GIT_BRANCH" = "" ] || cd "$SRCDIR/pcre" && git checkout "$GIT_BRANCH") && \
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
				nmake -f ../../winpcre.mak clean libpcre.lib >> "$LOGDIR/PCRE.log" 2>&1 && \
			cd "$SRCDIR"
		) \
	) && \
		\
	(echo "Building Sgmlop..." && \
		([ -d "$BUILDDIR/sgmlop" ] || (
			([ "$GIT_BRANCH" = "" ] || cd "$SRCDIR/sgmlop" && git checkout "$GIT_BRANCH") && \
			rm -rf "$BUILDDIR/sgmlop" && \
			cp -R "$SRCDIR/sgmlop" "$BUILDDIR/sgmlop" \
		)) && \
		cd "$BUILDDIR/sgmlop" && \
			$PYTHON setup.py build > "$LOGDIR/Sgmlop.log" 2>&1 && \
		cd "$SRCDIR"
	) && \
		\
	(echo "Patching Scintilla..." && \
		([ -d "$BUILDDIR/scintilla" ] || (
			([ "$GIT_BRANCH" = "" ] || cd "$SRCDIR/scintilla" && git checkout "$GIT_BRANCH") && \
			rm -rf "$BUILDDIR/scintilla" && \
			cp -R "$SRCDIR/scintilla" "$BUILDDIR/scintilla" \
		)) && \
		cd "$BUILDDIR/scintilla" && \
			cd include && \
				$PYTHON HFacer.py > "$LOGDIR/Scintilla.log" 2>&1 && \
		cd "$SRCDIR"
	) && \
		\
	(echo "Building SilverCity..." && \
		([ -d "$BUILDDIR/silvercity" ] || (
			([ "$GIT_BRANCH" = "" ] || cd "$SRCDIR/silvercity" && git checkout "$GIT_BRANCH") && \
			rm -rf "$BUILDDIR/silvercity" && \
			cp -R "$SRCDIR/silvercity" "$BUILDDIR/silvercity" \
		)) && \
		cd "$BUILDDIR/silvercity" && \
			cp -f "$LIBPCRE" . && \
			cd PySilverCity/Src && \
				$PYTHON write_scintilla.py \
					../../../scintilla/include/ \
					../../../scintilla/include/Scintilla.iface \
					../SilverCity/ScintillaConstants.py > "$LOGDIR/SilverCity.log" 2>&1 && \
			cd ../.. && \
			$PYTHON setup.py build >> "$LOGDIR/SilverCity.log" 2>&1 && \
		cd "$SRCDIR"
	) && \
		\
	(echo "Building cElementTree..." && \
		([ -d "$BUILDDIR/cElementTree" ] || (
			([ "$GIT_BRANCH" = "" ] || cd "$SRCDIR/cElementTree" && git checkout "$GIT_BRANCH") && \
			rm -rf "$BUILDDIR/cElementTree" && \
			cp -R "$SRCDIR/cElementTree" "$BUILDDIR/cElementTree" \
		)) && \
		cd "$BUILDDIR/cElementTree" && \
			$PYTHON setup.py build > "$LOGDIR/cElementTree.log" 2>&1 && \
		cd "$SRCDIR"
	) && \
		\
	(echo "Building ciElementTree..." && \
		([ -d "$BUILDDIR/ciElementTree" ] || (
			([ "$GIT_BRANCH" = "" ] || cd "$SRCDIR/ciElementTree" && git checkout "$GIT_BRANCH") && \
			rm -rf "$BUILDDIR/ciElementTree" && \
			cp -R "$SRCDIR/ciElementTree" "$BUILDDIR/ciElementTree" \
		)) && \
		cd "$BUILDDIR/ciElementTree" && \
			$PYTHON setup.py build > "$LOGDIR/ciElementTree.log" 2>&1 && \
		cd "$SRCDIR"
	) && \
		\
	(echo "Building UDL lexers..." && \
		([ -d "$BUILDDIR/udl" ] || (
			([ "$GIT_BRANCH" = "" ] || cd "$SRCDIR/udl" && git checkout "$GIT_BRANCH") && \
			rm -rf "$BUILDDIR/udl" && \
			cp -R "$SRCDIR/udl" "$BUILDDIR/udl" \
		)) && \
		cd "$BUILDDIR/udl" && \
			cp "$SRCDIR/more4sublime/chromereg.py" . && \
			find udl -type f -name '*-mainlex.udl' -exec $PYTHON luddite.py just_compile "{}" \; > "$LOGDIR/UDL.log" 2>&1 && \
		cd "$SRCDIR"
	) && \
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
