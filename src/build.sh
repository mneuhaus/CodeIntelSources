#!/bin/sh

GIT_BRANCH=""

CURRENT_PATH=`pwd`
LOGDIR="$CURRENT_PATH/build/logs"

ARG="$1"

if [ $OSTYPE = "linux-gnu" ]; then
	# In Linux, Sublime Text's Python is compiled with UCS4:
	echo "SublimeCodeIntel for Linux"
	echo "=========================="
	PYTHON="python"
	if [ `uname -m` == 'x86_64' ]; then
		CXXFLAGS="-fPIC -DPy_UNICODE_SIZE=4 -I $CURRENT_PATH/build/pcre $CXXFLAGS"
		CFLAGS="-fPIC -DPy_UNICODE_SIZE=4 -I $CURRENT_PATH/build/pcre $CFLAGS"
	else
		CXXFLAGS="-DPy_UNICODE_SIZE=4 -I $CURRENT_PATH/build/pcre $CXXFLAGS"
		CFLAGS="-DPy_UNICODE_SIZE=4 -I $CURRENT_PATH/build/pcre $CFLAGS"
	fi
	LIBPCRE="$CURRENT_PATH/build/pcre/.libs/libpcre.a"
	SO="so"
elif [ ${OSTYPE:0:6} = "darwin" ]; then
	echo "SublimeCodeIntel for Mac OS X"
	echo "============================="
	PYTHON="python"
	ARCHFLAGS="-arch i386 -arch x86_64 $ARCHFLAGS"
	CXXFLAGS="-arch i386 -arch x86_64 -I $CURRENT_PATH/build/pcre $CXXFLAGS"
	CFLAGS="-arch i386 -arch x86_64 -I $CURRENT_PATH/build/pcre $CFLAGS"
	LDFLAGS="-arch i386 -arch x86_64 $LDFLAGS"
	LIBPCRE="$CURRENT_PATH/build/pcre/.libs/libpcre.a"
	SO="so"
else
	if [[ "$FRAMEWORKDIR" == *"Framework64"* ]]; then
		echo "SublimeCodeIntel for Windows (amd64)"
		echo "===================================="
		PYTHON="C:/Python26-x64/python"
	else
		echo "SublimeCodeIntel for Windows (x86)"
		echo "=================================="
		PYTHON="C:/Python26/python"
	fi
	ERR=" (You need to have Visual Studio and run this script from the Command Prompt. You also need the following tools: bash, patch, find and python 2.6 available from the command line)"
	CXXFLAGS="-I $CURRENT_PATH/build/pcre $CXXFLAGS"
	CFLAGS="-I $CURRENT_PATH/build/pcre $CFLAGS"
	LIBPCRE="$CURRENT_PATH/build/pcre/libpcre.lib"
	OSTYPE=""
	SO="pyd"
fi

build() {
	if [ "$ARG" = "--force" ]; then
		rm -rf "build"
		rm -rf "$LOGDIR" && mkdir -p "$LOGDIR"
	fi

	mkdir -p "build/libs"

	( ([ "$OSTYPE" == "" ] || [ "$ARG" != "--force" ] && [ -d build/pcre ]) || (echo "Building PCRE (*nix)..." && \
		rm -rf build/pcre && \
		cp -R pcre build/pcre && \
		cd build/pcre && \
			([ "$GIT_BRANCH" == "" ] || git checkout "$GIT_BRANCH") && \
			./configure --disable-shared --disable-dependency-tracking --enable-utf8 --enable-unicode-properties > "$LOGDIR/PCRE.log" 2>&1 && \
			mkdir .libs && \
			make >> "$LOGDIR/PCRE.log" 2>&1 && \
		cd "$CURRENT_PATH"
	)) && \

	( ([ "$OSTYPE" != "" ] || [ "$ARG" != "--force" ] && [ -d build/pcre ]) || (echo "Building PCRE (win)..." && \
		rm -rf build/pcre && \
		cp -R pcre build/pcre && \
		cd build/pcre && \
			([ "$GIT_BRANCH" == "" ] || git checkout "$GIT_BRANCH") && \
			cp pcre.h.generic pcre.h && \
			cp config.h.generic config.h && \
			echo "#undef HAVE_DIRENT_H" >> config.h && \
			echo "#undef HAVE_INTTYPES_H" >> config.h && \
			echo "#undef HAVE_STDINT_H" >> config.h && \
			echo "#undef HAVE_UNISTD_H" >> config.h && \
			echo "#define HAVE_WINDOWS_H 1" >> config.h && \
			echo "#define SUPPORT_UCP" >> config.h && \
			echo "#define SUPPORT_UTF8" >> config.h && \
			nmake -f ../winpcre.mak clean libpcre.lib >> "$LOGDIR/PCRE.log" 2>&1 && \
		cd "$CURRENT_PATH"
	)) && \

	( ([ "$ARG" != "--force" ] && [ -d build/sgmlop ]) || (echo "Building Sgmlop..." && \
		rm -rf build/sgmlop && \
		cp -R sgmlop build/sgmlop && \
		cd build/sgmlop && \
			([ "$GIT_BRANCH" == "" ] || git checkout "$GIT_BRANCH") && \
			$PYTHON setup.py build > "$LOGDIR/Sgmlop.log" 2>&1 && \
		cd "$CURRENT_PATH"
	)) && \

	( ([ "$ARG" != "--force" ] && [ -d build/scintilla ]) || (echo "Patching Scintilla..." && \
		rm -rf build/scintilla && \
		cp -R scintilla build/scintilla && \
		cd build/scintilla && \
			([ "$GIT_BRANCH" == "" ] || git checkout "$GIT_BRANCH") && \
			cd include && \
				$PYTHON HFacer.py > "$LOGDIR/Scintilla.log" 2>&1 && \
		cd "$CURRENT_PATH"
	)) && \

	( ([ "$ARG" != "--force" ] && [ -d build/silvercity ]) || (echo "Building SilverCity..." && \
		rm -rf build/silvercity && \
		cp -R silvercity build/silvercity && \
		cd build/silvercity && \
			([ "$GIT_BRANCH" == "" ] || git checkout "$GIT_BRANCH") && \
			cp -f "$LIBPCRE" . && \
			cd PySilverCity/Src && \
				$PYTHON write_scintilla.py \
					../../../scintilla/include/ \
					../../../scintilla/include/Scintilla.iface \
					../SilverCity/ScintillaConstants.py > "$LOGDIR/SilverCity.log" 2>&1 && \
			cd ../.. && \
			$PYTHON setup.py build >> "$LOGDIR/SilverCity.log" 2>&1 && \
		cd "$CURRENT_PATH"
	)) && \

	( ([ "$ARG" != "--force" ] && [ -d build/cElementTree ]) || (echo "Building cElementTree..." && \
		rm -rf build/cElementTree && \
		cp -R cElementTree build/cElementTree && \
		cd build/cElementTree && \
			([ "$GIT_BRANCH" == "" ] || git checkout "$GIT_BRANCH") && \
			$PYTHON setup.py build > "$LOGDIR/cElementTree.log" 2>&1 && \
		cd "$CURRENT_PATH"
	)) && \

	( ([ "$ARG" != "--force" ] && [ -d build/udl ]) || (echo "Building UDL lexers..." && \
		rm -rf build/udl && \
		cp -R udl build/udl && \
		cd build/udl && \
			cp "../../more4sublime/chromereg.py" . && \
			find udl -type f -name '*-mainlex.udl' -exec $PYTHON luddite.py just_compile {} \; > "$LOGDIR/UDL.log" 2>&1 && \
		cd "$CURRENT_PATH"
	)) && \

	echo "Build Done!" || \
	echo "Build Failed!$ERR"

	if [ $OSTYPE != "" ]; then
		strip "build/libs/*.$SO" > /dev/null 2>&1
		strip -S "build/libs/*.$SO" > /dev/null 2>&1
	fi
}

if [ ! $DEPLOYING ]; then
	build
fi
