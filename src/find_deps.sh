#!/bin/sh

PYTHONPATH=.:silvercity/PySilverCity/:chardet/:python-sitelib/:smallstuff/

sfood --follow --internal --ignore-unused codeintel/lib/codeintel2/common.py codeintel/lib/codeintel2/manager.py codeintel/lib/codeintel2/citadel.py codeintel/lib/codeintel2/environment.py codeintel/lib/codeintel2/util.py codeintel/lib/codeintel2/lang_*.py | sfood-graph -p | dot -Tps | pstopdf -i -o deps.pdf
