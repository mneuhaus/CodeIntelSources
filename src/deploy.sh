#!/bin/sh
DEPLOYING=1

. build.sh

deploy() {
	DEPLOYMENT_PATH="../libs"

	find "$DEPLOYMENT_PATH/" -type f -name '*.pyc' -delete && \

	mkdir -p "$DEPLOYMENT_PATH/_local_arch" && \
	touch "$DEPLOYMENT_PATH/_local_arch/__init__.py" && \

	cp -Rf "codeintel/lib/codeintel2" "$DEPLOYMENT_PATH" && \
	mkdir -p "$DEPLOYMENT_PATH/codeintel2/lexers" && \
	echo "Deploying CodeIntel2..." && \

	find "build/udl/udl" -type f -name '*.lexres' -exec cp -f {} "$DEPLOYMENT_PATH/codeintel2/lexers" \; > /dev/null 2>&1 && \
	find "build/udl/skel" -type f -name 'lang_*.py' -exec cp -f {} "$DEPLOYMENT_PATH/codeintel2" \; > /dev/null 2>&1 && \
	echo "Deploying UDL..." && \

	cp -Rf "build/silvercity/PySilverCity/SilverCity" "$DEPLOYMENT_PATH" && \
	cp -f "more4sublime/libs/_SilverCity.py" "$DEPLOYMENT_PATH/SilverCity" && \
	find "build" -type f -name "_SilverCity.$SO" -exec cp -f {} "build/libs" \; > /dev/null 2>&1
	echo "Deploying SilverCity..." && \

	cp -f "more4sublime/libs/ciElementTree.py" "$DEPLOYMENT_PATH" && \
	find "build" -type f -name "ciElementTree.$SO" -exec cp -f {} "build/libs" \; > /dev/null 2>&1
	echo "Deploying ciElementTree..." && \

	cp -f "more4sublime/libs/sgmlop.py" "$DEPLOYMENT_PATH" && \
	find "build" -type f -name "sgmlop.$SO" -exec cp -f {} "build/libs" \; > /dev/null 2>&1
	echo "Deploying Sgmlop..." && \

	cp -f "more4sublime/styles.py" "$DEPLOYMENT_PATH" && \
	cp -f "smallstuff/winprocess.py" "$DEPLOYMENT_PATH" && \
	cp -f "python-sitelib/HTMLTreeParser.py" "$DEPLOYMENT_PATH" && \
	cp -f "python-sitelib/koCatalog.py" "$DEPLOYMENT_PATH" && \
	cp -f "python-sitelib/koDTD.py" "$DEPLOYMENT_PATH" && \
	cp -f "python-sitelib/koRNGElementTree.py" "$DEPLOYMENT_PATH" && \
	cp -f "python-sitelib/koSimpleLexer.py" "$DEPLOYMENT_PATH" && \
	cp -f "python-sitelib/koXMLDatasetInfo.py" "$DEPLOYMENT_PATH" && \
	cp -f "python-sitelib/koXMLTreeService.py" "$DEPLOYMENT_PATH" && \
	cp -f "python-sitelib/langinfo.py" "$DEPLOYMENT_PATH" && \
	cp -f "python-sitelib/langinfo_binary.py" "$DEPLOYMENT_PATH" && \
	cp -f "python-sitelib/langinfo_doc.py" "$DEPLOYMENT_PATH" && \
	cp -f "python-sitelib/langinfo_komodo.py" "$DEPLOYMENT_PATH" && \
	cp -f "python-sitelib/langinfo_mozilla.py" "$DEPLOYMENT_PATH" && \
	cp -f "python-sitelib/langinfo_other.py" "$DEPLOYMENT_PATH" && \
	cp -f "python-sitelib/langinfo_prog.py" "$DEPLOYMENT_PATH" && \
	cp -f "python-sitelib/langinfo_template.py" "$DEPLOYMENT_PATH" && \
	cp -f "python-sitelib/langinfo_tiny.py" "$DEPLOYMENT_PATH" && \
	cp -f "python-sitelib/process.py" "$DEPLOYMENT_PATH" && \
	cp -f "python-sitelib/textinfo.py" "$DEPLOYMENT_PATH" && \
	cp -f "python-sitelib/which.py" "$DEPLOYMENT_PATH" && \

	cp -Rf "chardet/chardet" "$DEPLOYMENT_PATH" && \

	cp -Rf "elementtree/elementtree" "$DEPLOYMENT_PATH" && \

	cp -Rf "inflector" "$DEPLOYMENT_PATH" && \
	echo "Deploying Libs..." && \

	echo "Deployment Done!" || \
	echo "Deployment Failed!"
}

if [ ! -d build ] || [ "$ARG" == "--force" ]; then
	build
fi

deploy
