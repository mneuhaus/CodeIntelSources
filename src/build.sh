#!/bin/sh

GIT_BRANCH=""

CURRENT_PATH=`pwd`
LOGDIR="$CURRENT_PATH/build/logs"

rm -rf "build"
rm -rf "$LOGDIR" && mkdir -p "$LOGDIR"
mkdir -p "build/libs"

if [ $OSTYPE = "linux-gnu" ]; then
	# In Linux, Sublime Text's Python is compiled with UCS4:
	echo "Linux build!"
	if [ `uname -m` == 'x86_64' ]; then
		export CXXFLAGS="-fPIC -DPy_UNICODE_SIZE=4 -I build/pcre $CFLAGS"
		export CFLAGS="-fPIC -DPy_UNICODE_SIZE=4 -I build/pcre $CFLAGS"
	else
		export CXXFLAGS="-DPy_UNICODE_SIZE=4 -I build/pcre $CFLAGS"
		export CFLAGS="-DPy_UNICODE_SIZE=4 -I build/pcre $CFLAGS"
	fi
	LIBPCRE="$CURRENT_PATH/build/pcre/.libs/libpcre.a"
	PYTHON="python"
	SO="so"
elif [ ${OSTYPE:0:6} = "darwin" ]; then
	echo "Mac OS X build!"
	export ARCHFLAGS="-arch i386 -arch x86_64 $ARCHFLAGS"
	export CXXFLAGS="-arch i386 -arch x86_64 -I build/pcre $CFLAGS"
	export CFLAGS="-arch i386 -arch x86_64 -I build/pcre $CFLAGS"
	export LDFLAGS="-arch i386 -arch x86_64 $LDFLAGS"
	LIBPCRE="$CURRENT_PATH/build/pcre/.libs/libpcre.a"
	PYTHON="python"
	SO="so"
else
	if [[ "$FRAMEWORKDIR" == *"Framework64"* ]]; then
		echo "Windows (amd64) build!"
		PYTHON="C:/Python26-x64/python"
	else
		echo "Windows (x86) build!"
		PYTHON="C:/Python26/python"
	fi
	ERR=" (You need to have Visual Studio and run this script from the Command Prompt. You also need the following tools: bash, patch, find and python 2.6 available from the command line)"
	export CXXFLAGS="-I build/pcre $CFLAGS"
	export CFLAGS="-I build/pcre $CFLAGS"
	LIBPCRE="$CURRENT_PATH/build/pcre/libpcre.lib"
	OSTYPE=""
	SO="pyd"
fi

([ "$OSTYPE" == "" ] || (echo "Building PCRE (*nix)..." && \
	cp -R pcre build/pcre && \
	cd build/pcre && \
		([ "$GIT_BRANCH" == "" ] || git checkout "$GIT_BRANCH") && \
		./configure --disable-shared --disable-dependency-tracking --enable-utf8 --enable-unicode-properties > "$LOGDIR/PCRE.log" 2>&1 && \
		mkdir .libs && \
		make >> "$LOGDIR/PCRE.log" 2>&1 && \
	cd "$CURRENT_PATH"
)) && \

([ "$OSTYPE" != "" ] || (echo "Building PCRE (win)..." && \
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

(echo "Building Sgmlop..." && \
	cp -R sgmlop build/sgmlop && \
	cd build/sgmlop && \
		([ "$GIT_BRANCH" == "" ] || git checkout "$GIT_BRANCH") && \
		$PYTHON setup.py build > "$LOGDIR/Sgmlop.log" 2>&1 && \
	cd "$CURRENT_PATH"
) && \

(echo "Patching Scintilla..." && \
	cp -R scintilla build/scintilla && \
	cd build/scintilla && \
		([ "$GIT_BRANCH" == "" ] || git checkout "$GIT_BRANCH") && \
		cd include && \
			$PYTHON HFacer.py > "$LOGDIR/Scintilla.log" 2>&1 && \
	cd "$CURRENT_PATH"
) && \

(echo "Building SilverCity..." && \
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
) && \

(echo "Building cElementTree..." && \
	cp -R cElementTree build/cElementTree && \
	cd build/cElementTree && \
		([ "$GIT_BRANCH" == "" ] || git checkout "$GIT_BRANCH") && \
		$PYTHON setup.py build > "$LOGDIR/cElementTree.log" 2>&1 && \
	cd "$CURRENT_PATH"
) && \

(echo "Building UDL lexers..." && \
	cp -R udl build/udl && \
	cd build/udl && \
		cp "../../more4sublime/chromereg.py" . && \
		find udl -name '*-mainlex.udl' -exec $PYTHON luddite.py just_compile {} \; > "$LOGDIR/UDL.log" 2>&1 && \
	cd "$CURRENT_PATH"
) && \

find "build" -type f -name "sgmlop.$SO" -exec cp {} "build/libs" \; && \
find "build" -type f -name "ciElementTree.$SO" -exec cp {} "build/libs" \; && \
find "build" -type f -name "_SilverCity.$SO" -exec cp {} "build/libs" \; && \

echo "Build Done!" || \
echo "Build Failed!$ERR"

if [ $OSTYPE != "" ]; then
	strip "build/libs/*.$SO" > /dev/null 2>&1
	strip -S "build/libs/*.$SO" > /dev/null 2>&1
fi
