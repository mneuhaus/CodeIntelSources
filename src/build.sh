#!/bin/sh
cd "`dirname "$0"`"
SRCDIR=`pwd`
ARG="$1"

GIT_BRANCH=""

if [ $OSTYPE = "linux-gnu" ]; then
	# In Linux, Sublime Text's Python is compiled with UCS4:
	echo "SublimeCodeIntel for Linux"
	echo "=========================="
	BUILDDIR="$SRCDIR/build"
	PYTHON="python"
	if [ `uname -m` == 'x86_64' ]; then
		CXXFLAGS="-fPIC -DPy_UNICODE_SIZE=4 -I $BUILDDIR/pcre $CXXFLAGS"
		CFLAGS="-fPIC -DPy_UNICODE_SIZE=4 -I $BUILDDIR/pcre $CFLAGS"
	else
		CXXFLAGS="-DPy_UNICODE_SIZE=4 -I $BUILDDIR/pcre $CXXFLAGS"
		CFLAGS="-DPy_UNICODE_SIZE=4 -I $BUILDDIR/pcre $CFLAGS"
	fi
	LIBPCRE="$BUILDDIR/pcre/.libs/libpcre.a"
	SO="so"
elif [ ${OSTYPE:0:6} = "darwin" ]; then
	echo "SublimeCodeIntel for Mac OS X"
	echo "============================="
	BUILDDIR="$SRCDIR/build"
	PYTHON="python"
	ARCHFLAGS="-arch i386 -arch x86_64 $ARCHFLAGS"
	CXXFLAGS="-arch i386 -arch x86_64 -I $BUILDDIR/pcre $CXXFLAGS"
	CFLAGS="-arch i386 -arch x86_64 -I $BUILDDIR/pcre $CFLAGS"
	LDFLAGS="-arch i386 -arch x86_64 $LDFLAGS"
	LIBPCRE="$BUILDDIR/pcre/.libs/libpcre.a"
	SO="so"
else
	if [[ "$FRAMEWORKDIR" == *"Framework64"* ]]; then
		echo "SublimeCodeIntel for Windows (amd64)"
		echo "===================================="
		BUILDDIR="$SRCDIR/build"
		PYTHON="C:/Python26-x64/python.exe"
	else
		echo "SublimeCodeIntel for Windows (x86)"
		echo "=================================="
		BUILDDIR="$SRCDIR/build"
		PYTHON="C:/Python26/python.exe"
	fi
	ERR=" (You need to have Visual Studio and run this script from the Command Prompt. You also need the following tools: bash, patch, find and python 2.6 available from the command line.)"
	if [ ! -f "$PYTHON" ]; then
		ERR="$ERR Python must exist at $PYTHON"
		PYTHON="python"
	fi
	CXXFLAGS="-I $BUILDDIR/pcre $CXXFLAGS"
	CFLAGS="-I $BUILDDIR/pcre $CFLAGS"
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
	rm -rf "$BUILDDIR"
	mkdir -p "$LOGDIR"

	echo "Building..." && \
	([ "$OSTYPE" = "" ] || ([ "$ARG" != "--force" ] && [ -d "$BUILDDIR/pcre" ] || echo "Building PCRE (*nix)..." && \
		rm -rf "$BUILDDIR/pcre" && \
		cp -R "$SRCDIR/pcre" "$BUILDDIR/pcre" && \
		cd "$BUILDDIR/pcre" && \
			([ "$GIT_BRANCH" == "" ] || git checkout "$GIT_BRANCH") && \
			./configure --disable-shared --disable-dependency-tracking --enable-utf8 --enable-unicode-properties > "$LOGDIR/PCRE.log" 2>&1 && \
			mkdir .libs && \
			make >> "$LOGDIR/PCRE.log" 2>&1 && \
		cd "$SRCDIR"
	)) && \
		\
	([ "$OSTYPE" != "" ] || ([ "$ARG" != "--force" ] && [ -d "$BUILDDIR/pcre" ] || echo "Building PCRE (win)..." && \
		rm -rf "$BUILDDIR/pcre" && \
		cp -R "$SRCDIR/pcre" "$BUILDDIR/pcre" && \
		cd "$BUILDDIR/pcre" && \
			([ "$GIT_BRANCH" == "" ] || git checkout "$GIT_BRANCH") && \
			cp "Win32/pcre.h" "pcre.h" && \
			cp "Win32/config.h" "config.h" && \
			echo "#undef HAVE_DIRENT_H" >> config.h && \
			echo "#undef HAVE_INTTYPES_H" >> config.h && \
			echo "#undef HAVE_STDINT_H" >> config.h && \
			echo "#undef HAVE_UNISTD_H" >> config.h && \
			echo "#define HAVE_WINDOWS_H 1" >> config.h && \
			echo "#define SUPPORT_UCP" >> config.h && \
			echo "#define SUPPORT_UTF8" >> config.h && \
			nmake -f ../../winpcre.mak clean libpcre.lib >> "$LOGDIR/PCRE.log" 2>&1 && \
		cd "$SRCDIR"
	)) && \
		\
	([ "$ARG" != "--force" ] && [ -d "$BUILDDIR/sgmlop" ] || echo "Building Sgmlop..." && \
		rm -rf "$BUILDDIR/sgmlop" && \
		cp -R "$SRCDIR/sgmlop" "$BUILDDIR/sgmlop" && \
		cd "$BUILDDIR/sgmlop" && \
			([ "$GIT_BRANCH" == "" ] || git checkout "$GIT_BRANCH") && \
			$PYTHON setup.py build > "$LOGDIR/Sgmlop.log" 2>&1 && \
		cd "$SRCDIR"
	) && \
		\
	([ "$ARG" != "--force" ] && [ -d "$BUILDDIR/scintilla" ] || echo "Patching Scintilla..." && \
		rm -rf "$BUILDDIR/scintilla" && \
		cp -R "$SRCDIR/scintilla" "$BUILDDIR/scintilla" && \
		cd "$BUILDDIR/scintilla" && \
			([ "$GIT_BRANCH" == "" ] || git checkout "$GIT_BRANCH") && \
			cd include && \
				$PYTHON HFacer.py > "$LOGDIR/Scintilla.log" 2>&1 && \
		cd "$SRCDIR"
	) && \
		\
	([ "$ARG" != "--force" ] && [ -d "$BUILDDIR/silvercity" ] || echo "Building SilverCity..." && \
		rm -rf "$BUILDDIR/silvercity" && \
		cp -R "$SRCDIR/silvercity" "$BUILDDIR/silvercity" && \
		cd "$BUILDDIR/silvercity" && \
			([ "$GIT_BRANCH" == "" ] || git checkout "$GIT_BRANCH") && \
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
	([ "$ARG" != "--force" ] && [ -d "$BUILDDIR/cElementTree" ] || echo "Building cElementTree..." && \
		rm -rf "$BUILDDIR/cElementTree" && \
		cp -R "$SRCDIR/cElementTree" "$BUILDDIR/cElementTree" && \
		cd "$BUILDDIR/cElementTree" && \
			([ "$GIT_BRANCH" == "" ] || git checkout "$GIT_BRANCH") && \
			$PYTHON setup.py build > "$LOGDIR/cElementTree.log" 2>&1 && \
		cd "$SRCDIR"
	) && \
		\
	([ "$ARG" != "--force" ] && [ -d "$BUILDDIR/udl" ] || echo "Building UDL lexers..." && \
		rm -rf "$BUILDDIR/udl" && \
		cp -R "$SRCDIR/udl" "$BUILDDIR/udl" && \
		cd "$BUILDDIR/udl" && \
			cp "../../more4sublime/chromereg.py" . && \
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
