#!/bin/sh

DEPLOYMENT_PATH="../libs"

mkdir -p "$DEPLOYMENT_PATH/_local_arch" && \

cp -Rf "chardet/chardet" "$DEPLOYMENT_PATH" && \

cp -Rf "elementtree/elementtree" "$DEPLOYMENT_PATH" && \

cp -Rf "inflector" "$DEPLOYMENT_PATH" && \

cp -Rf "codeintel/lib/codeintel2" "$DEPLOYMENT_PATH" && \
mkdir -p "$DEPLOYMENT_PATH/codeintel2/lexers" && cp "build/udl/udl/"*.lexres "$DEPLOYMENT_PATH/codeintel2/lexers" && \

cp -Rf "silvercity/PySilverCity/SilverCity" "$DEPLOYMENT_PATH" && \
cp -Rf "more4sublime/libs/_SilverCity.py" "$DEPLOYMENT_PATH/SilverCity" && \

cp -Rf "more4sublime/libs/ciElementTree.py" "$DEPLOYMENT_PATH" && \

cp -Rf "more4sublime/libs/sgmlop.py" "$DEPLOYMENT_PATH" && \

cp -Rf "more4sublime/styles.py" "$DEPLOYMENT_PATH" && \
cp -Rf "smallstuff/winprocess.py" "$DEPLOYMENT_PATH" && \
cp -Rf "python-sitelib/HTMLTreeParser.py" "$DEPLOYMENT_PATH" && \
cp -Rf "python-sitelib/koCatalog.py" "$DEPLOYMENT_PATH" && \
cp -Rf "python-sitelib/koDTD.py" "$DEPLOYMENT_PATH" && \
cp -Rf "python-sitelib/koRNGElementTree.py" "$DEPLOYMENT_PATH" && \
cp -Rf "python-sitelib/koSimpleLexer.py" "$DEPLOYMENT_PATH" && \
cp -Rf "python-sitelib/koXMLDatasetInfo.py" "$DEPLOYMENT_PATH" && \
cp -Rf "python-sitelib/koXMLTreeService.py" "$DEPLOYMENT_PATH" && \
cp -Rf "python-sitelib/langinfo.py" "$DEPLOYMENT_PATH" && \
cp -Rf "python-sitelib/langinfo_binary.py" "$DEPLOYMENT_PATH" && \
cp -Rf "python-sitelib/langinfo_doc.py" "$DEPLOYMENT_PATH" && \
cp -Rf "python-sitelib/langinfo_komodo.py" "$DEPLOYMENT_PATH" && \
cp -Rf "python-sitelib/langinfo_mozilla.py" "$DEPLOYMENT_PATH" && \
cp -Rf "python-sitelib/langinfo_other.py" "$DEPLOYMENT_PATH" && \
cp -Rf "python-sitelib/langinfo_prog.py" "$DEPLOYMENT_PATH" && \
cp -Rf "python-sitelib/langinfo_template.py" "$DEPLOYMENT_PATH" && \
cp -Rf "python-sitelib/langinfo_tiny.py" "$DEPLOYMENT_PATH" && \
cp -Rf "python-sitelib/process.py" "$DEPLOYMENT_PATH" && \
cp -Rf "python-sitelib/textinfo.py" "$DEPLOYMENT_PATH" && \
cp -Rf "python-sitelib/which.py" "$DEPLOYMENT_PATH" && \

echo "Deployment Done!" || \
echo "Deployment Failed!"
