#!/usr/bin/env bash
cd "`dirname "$0"`"
SRCDIR=`pwd`
ARG="$1"

DEPLOYMENTDIR="../SublimeCodeIntel"

DEPLOYING=1
. build.sh

deploy() {
	mkdir -p "$DEPLOYMENTDIR/libs" && \
	mkdir -p "$DEPLOYMENTDIR/arch/_local_arch" && \
	touch "$DEPLOYMENTDIR/arch/_local_arch/__init__.py" && \
		\
	find "$DEPLOYMENTDIR/libs" -type f -name '*.pyc' -exec rm "{}" \; && \
		\
	echo "Deploying CodeIntel2..." && \
	cp -Rf "$SRCDIR/codeintel/lib/codeintel2" "$DEPLOYMENTDIR/libs" && \
	mkdir -p "$DEPLOYMENTDIR/libs/codeintel2/lexers" && \
		\
	echo "Deploying UDL..." && \
	find "$BUILDDIR/udl/udl" -type f -name '*.lexres' -exec cp -f "{}" "$DEPLOYMENTDIR/libs/codeintel2/lexers" \; && \
	find "$BUILDDIR/udl/skel" -type f -name 'lang_*.py' -exec cp -f "{}" "$DEPLOYMENTDIR/libs/codeintel2" \; && \
		\
	echo "Deploying SilverCity..." && \
	cp -Rf "$BUILDDIR/silvercity/PySilverCity/SilverCity" "$DEPLOYMENTDIR/libs" && \
	cp -f "$SRCDIR/more4sublime/libs/_SilverCity.py" "$DEPLOYMENTDIR/libs/SilverCity" && \
	find "$BUILDDIR/silvercity" -type f -name "_SilverCity.$SO" -exec cp -f "{}" "$DEPLOYMENTDIR/arch/_local_arch" \; && \
		\
	echo "Deploying ciElementTree..." && \
	cp -f "$SRCDIR/more4sublime/libs/ciElementTree.py" "$DEPLOYMENTDIR/libs" && \
	find "$BUILDDIR/cElementTree" -type f -name "ciElementTree.$SO" -exec cp -f "{}" "$DEPLOYMENTDIR/arch/_local_arch" \; && \
		\
	echo "Deploying Sgmlop..." && \
	cp -f "$SRCDIR/more4sublime/libs/sgmlop.py" "$DEPLOYMENTDIR/libs" && \
	find "$BUILDDIR/sgmlop" -type f -name "sgmlop.$SO" -exec cp -f "{}" "$DEPLOYMENTDIR/arch/_local_arch" \; && \
		\
	echo "Deploying Libs..." && \
	cp -f "$SRCDIR/more4sublime/styles.py" "$DEPLOYMENTDIR/libs" && \
	cp -f "$SRCDIR/smallstuff/winprocess.py" "$DEPLOYMENTDIR/libs" && \
	cp -f "$SRCDIR/python-sitelib/HTMLTreeParser.py" "$DEPLOYMENTDIR/libs" && \
	cp -f "$SRCDIR/python-sitelib/koCatalog.py" "$DEPLOYMENTDIR/libs" && \
	cp -f "$SRCDIR/python-sitelib/koDTD.py" "$DEPLOYMENTDIR/libs" && \
	cp -f "$SRCDIR/python-sitelib/koRNGElementTree.py" "$DEPLOYMENTDIR/libs" && \
	cp -f "$SRCDIR/python-sitelib/koSimpleLexer.py" "$DEPLOYMENTDIR/libs" && \
	cp -f "$SRCDIR/python-sitelib/koXMLDatasetInfo.py" "$DEPLOYMENTDIR/libs" && \
	cp -f "$SRCDIR/python-sitelib/koXMLTreeService.py" "$DEPLOYMENTDIR/libs" && \
	cp -f "$SRCDIR/python-sitelib/langinfo.py" "$DEPLOYMENTDIR/libs" && \
	cp -f "$SRCDIR/python-sitelib/langinfo_binary.py" "$DEPLOYMENTDIR/libs" && \
	cp -f "$SRCDIR/python-sitelib/langinfo_doc.py" "$DEPLOYMENTDIR/libs" && \
	cp -f "$SRCDIR/python-sitelib/langinfo_komodo.py" "$DEPLOYMENTDIR/libs" && \
	cp -f "$SRCDIR/python-sitelib/langinfo_mozilla.py" "$DEPLOYMENTDIR/libs" && \
	cp -f "$SRCDIR/python-sitelib/langinfo_other.py" "$DEPLOYMENTDIR/libs" && \
	cp -f "$SRCDIR/python-sitelib/langinfo_prog.py" "$DEPLOYMENTDIR/libs" && \
	cp -f "$SRCDIR/python-sitelib/langinfo_template.py" "$DEPLOYMENTDIR/libs" && \
	cp -f "$SRCDIR/python-sitelib/langinfo_tiny.py" "$DEPLOYMENTDIR/libs" && \
	cp -f "$SRCDIR/python-sitelib/process.py" "$DEPLOYMENTDIR/libs" && \
	cp -f "$SRCDIR/python-sitelib/textinfo.py" "$DEPLOYMENTDIR/libs" && \
	cp -f "$SRCDIR/python-sitelib/which.py" "$DEPLOYMENTDIR/libs" && \
		\
	cp -Rf "$SRCDIR/chardet/chardet" "$DEPLOYMENTDIR/libs" && \
		\
	cp -Rf "$SRCDIR/elementtree/elementtree" "$DEPLOYMENTDIR/libs" && \
		\
	cp -Rf "$SRCDIR/inflector" "$DEPLOYMENTDIR/libs" && \
		\
	echo "Deployment Done!" || \
	echo "Deployment Failed!"
}

if [ ! -d "$SRCDIR/build" ] || [ "$ARG" = "--force" ]; then
	build
fi

deploy
