Repositories
============

Most of the repositories in ``SublimeCodeIntel/src`` come from openkomodo SVN repository at ``http://svn.openkomodo.com/repos/openkomodo/trunk``

Generally, in our fork of these repositories, there are branches ``master``, ``svn``, ``pep8``, ``patched`` and ``patched-pep8``, ``py3``:

	* Branch ``svn`` is the one updated directly from OpenKomodo's SVN (updated when ``svn-rebase.sh`` is run)

	* Branch ``pep8`` is ``svn`` + ``autopep8 -virj 0 .``

	* Branch ``patched`` is ``svn`` + all relevant OpenKomodo patches.

	* Branch ``patched-pep8`` is ``patched`` + ``autopep8 -virj 0 .``

	* Branch ``master`` is ``patched-pep8`` + SublimeCodeIntel patches.

	* Branch ``py3`` is a python-modernized ``master``.


Tools
=====

There are a few tools to help fetching and maintaining updated the codebase of SublimeCodeIntel:

	* ``svn-clone.sh`` makes clones from SVN repositories (as a reference of how the repositories were built, in case it's ever needed again)

	* ``svn-rebase.sh`` is the one which actual upgrades stuff from the SVN, cleans the code, applies patches and so on.


OpenKomodo Patches
==================

There are three sets of patches in Open Komodo:

	* The ones in the repository ``patches`` in the ``/`` directory (which come from ``http://svn.openkomodo.com/repos/openkomodo/trunk/contrib/patches``). These are for several modules, but they all have already been applied by the OpenKomodo team to the official SVN repository.

	* The ones in the repository ``patches`` in the directory ``/scintilla``. These are all for scintilla and need to be applied during the building of Code Intel dependencies

	* The ones in the repository ``codeintel`` in the directory ``/src/patches``. These are all to convert cElementTree to ``ciElementTree`` (a more efficient version of ``cElementTree``)


Build Process
=============

The repository ``codeintel``, within SublimeCodeIntel's repositories, is the heart of CodeIntel2.

Libraries/Modules
-----------------
SublimeCodeIntel requires a lot of libraries/modules to work.

The following are in C/C++ and need to be compiled:

	* ``silvercity``: Used by CodeIntel2 to parse the user's source code in most (if not all) languages, like CSS/Python/JavaScript/Ruby/etc.

	* ``scintilla``: Library used by ``SilverCity``. This library is the one which actually does the heavy lifting and parsing of all user's source code.

	* ``pcre``: Library used by Scintilla (and should be linked statically to avoid version problems in linux and other systems)

	* ``cElementTree``: or more precisely ``ciElementTree`` (the patched, more efficient version of ``cElementTree``). Module used to parse some user's source code in some languages, like HTML/XML. And also to read the symbol catalogs, which all are XML files with the extension ``.cix``.

	* ``sgmlop``: Module used by ``elementtree`` and ``HTMLTreeParser``


The following have their own fork at SublimeCodeIntel's repositories and are in pure python and need not to be compiled:

	* ``python-sitelib``: There are all pure python "foundation" modules/libraries used by CodeIntel2. Some of these modules are used, some of them are not. The following are used by CodeIntel2:
		- ``HTMLTreeParser.py``
		- ``koCatalog.py``
		- ``koDTD.py``
		- ``koRNGElementTree.py``
		- ``koSimpleLexer.py``
		- ``koXMLDatasetInfo.py``
		- ``koXMLTreeService.py``
		- ``langinfo.py``
		- ``langinfo_binary.py``
		- ``langinfo_doc.py``
		- ``langinfo_komodo.py``
		- ``langinfo_mozilla.py``
		- ``langinfo_other.py``
		- ``langinfo_prog.py``
		- ``langinfo_template.py``
		- ``langinfo_tiny.py``
		- ``process.py``
		- ``textinfo.py``
		- ``which.py``

	* ``inflector``: Used by the Rails language parser to build a "migration class tree". This has a problem in the Spanish module with mixed characters in the wrong encoding.

	* ``chardet``: Module used by ``textinfo`` (not included in the OpenKomodo official repository). This is used to detect the encoding of the text being passed to CodeIntel2 if no encoding is provided.

	* ``smallstuff``: Some of the modules in here were collected from other sources and were also not included in the OpenKomodo official repository, but are also used.

	* Other used files scattered in the sources of OpenKomodo (and placed inside more4sublime):
		- ``libs/*.py``: Created by Kronuz for cross platform imports
		- ``styles.py``: ``/openkomodo/src/schemes/styles.py``
		- ``chromereg.py``: ``/openkomodo/src/sdk//pylib/chromereg.py``
