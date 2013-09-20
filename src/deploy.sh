#!/usr/bin/env bash

DEPLOYING=1
source build.sh

ARCHDIR="${ARCHDIR//py27/py26}"

xcp() {
	if [ "${OSTYPE:0:5}" = "linux" ] || [ "${OSTYPE:0:6}" = "darwin" ]; then
		xargs -I'{}' cp -f "$1" "$2"
	else
		xargs -i'{}' cp -f "$1" "$2"
	fi
}

deploy() {
	echo "Deploying [$ARCH, python v$PYVER -> $ARCHDIR] (${GIT_BRANCH:-unknown} branch)..." && \
	checkout && \
		\
	mkdir -p "$DEPLOYMENTDIR/libs" && \
	mkdir -p "$DEPLOYMENTDIR/arch/$ARCHDIR" && \
	touch "$DEPLOYMENTDIR/arch/$ARCHDIR/__init__.py" && \
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
	cp -f "$SRCDIR/more4sublime/libs/_SilverCity.py" "$DEPLOYMENTDIR/libs" && \
	find "$BUILDDIR/silvercity" -type f -name "_SilverCity*.$SO" | grep "$PYVER" | xcp "{}" "$DEPLOYMENTDIR/arch/$ARCHDIR/_SilverCity.$SO" && \
		\
	( \
		([ "${PYVER:0:1}" = "2" ] && (
			echo "Deploying cElementTree..." && \
			cp -f "$SRCDIR/more4sublime/libs/cElementTree.py" "$DEPLOYMENTDIR/libs" && \
			find "$BUILDDIR/cElementTree" -type f -name "cElementTree*.$SO" | grep "$PYVER" | xcp "{}" "$DEPLOYMENTDIR/arch/$ARCHDIR/cElementTree.$SO" && \
				\
			echo "Deploying ciElementTree..." && \
			cp -f "$SRCDIR/more4sublime/libs/ciElementTree.py" "$DEPLOYMENTDIR/libs" && \
			find "$BUILDDIR/ciElementTree" -type f -name "ciElementTree*.$SO" | grep "$PYVER" | xcp "{}" "$DEPLOYMENTDIR/arch/$ARCHDIR/ciElementTree.$SO"
		)) || \
		([ "${PYVER:0:1}" = "3" ] && (
			echo "Deploying iElementTree..." && \
			cp -f "$SRCDIR/more4sublime/libs/_ielementtree.py" "$DEPLOYMENTDIR/libs" && \
			cp -f "$SRCDIR/more4sublime/libs/iElementTree.py" "$DEPLOYMENTDIR/libs" && \
			cp -f "$SRCDIR/more4sublime/libs/cElementTree.py" "$DEPLOYMENTDIR/libs" && \
			cp -f "$SRCDIR/more4sublime/libs/ciElementTree.py" "$DEPLOYMENTDIR/libs" && \
			find "$BUILDDIR/iElementTree" -type f -name "_ielementtree*.$SO" | grep "$PYVER" | xcp "{}" "$DEPLOYMENTDIR/arch/$ARCHDIR/_ielementtree.$SO"
		)) \
	) && \
		\
	echo "Deploying Sgmlop..." && \
	cp -f "$SRCDIR/more4sublime/libs/sgmlop.py" "$DEPLOYMENTDIR/libs" && \
	find "$BUILDDIR/sgmlop" -type f -name "sgmlop*.$SO" | grep "$PYVER" | xcp "{}" "$DEPLOYMENTDIR/arch/$ARCHDIR/sgmlop.$SO" && \
		\
	( \
		([ "${PYVER:0:1}" = "2" ] && (
			echo "Deploying Chardet..." && \
			cp -Rf "$SRCDIR/chardet/chardet" "$DEPLOYMENTDIR/libs" \
		)) || \
		([ "${PYVER:0:1}" = "3" ] && (
			echo "Deploying Python 3 Chardet..." && \
			cp -Rf "$SRCDIR/python3-chardet/chardet" "$DEPLOYMENTDIR/libs" \
		)) \
	) && \
		\
	echo "Deploying zope.cachedescriptors..." && \
	mkdir -p "$DEPLOYMENTDIR/libs/zope" && \
	touch "$DEPLOYMENTDIR/libs/zope/__init__.py" && \
	cp -Rf "$SRCDIR/zope.cachedescriptors/src/zope/cachedescriptors" "$DEPLOYMENTDIR/libs/zope" && \
		\
	echo "Deploying Helper Libs..." && \
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
	cp -Rf "$SRCDIR/elementtree/elementtree" "$DEPLOYMENTDIR/libs"
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
