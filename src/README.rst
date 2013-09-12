Building Process
================

Make sure to fetch all the code dependencies by running: ``git submodule update --init --recursive``.

For pulling new stuff, use: ``git pull --recurse-submodules``.


* Under Max OS X:
	+ All needed dependencies come with Xcode.

	+ Go to the ``src`` directory and run::

		$ bash build.sh

		$ bash deploy


* Under Linux:
	+ Dependencies likely to be packaged on your system. For Ubuntu/Debian-like distros, open a terminal and do::

		$ sudo apt-get install g++

		$ sudo apt-get install python-dev

	+ Make sure the python development environment installed is for Python 2.6 (which is the one Sublime Text 2 uses)

	+ Go to the ``src`` directory and run::

		$ bash build.sh

		$ bash deploy


* Under Windows:
	+ Dependencies for Sublime Text 2 compatible plugin are:

		- Visual Studio 2008

		- Python 2.6 installed at C:\Python26\python.exe (for x86) or C:\Python26-x64\python.exe (for amd64)

		- Other dependencies are windows versions of ``bash``, ``patch`` and ``find``

	+ Dependencies for Sublime Text 3 compatible plugin are:

		- Visual Studio 2008 or 2010 (Tested with VS 2008)

		- Python 3.3 installed at C:\Python33\python.exe (for x86) or C:\Python33-x64\python.exe (for amd64)

		- If using Visual Studio 2008, it requires to do the following:

			- Set the environment variable:

				> SET VS100COMNTOOLS=%VS90COMNTOOLS%

			- Use a patched version of distutils (to have the standard libraries linked statically)::

				Edit ``C:\Python33\Lib\distutils\msvc9compiler.py`` and change all instances of ``/MD`` to ``/MT``.

	+ Open a command prompt using Viaual Studio Command Prompt (for x86) or Visual Studio x64 Win64 Command prompt (for amd64), then go to the ``src`` directory and run::

		> bash build.sh

		> bash deploy.sh

	+ For other example, to build in 64 bit Windows, using Python 3.3, run::

		> bash -c "PYTHON=C:/Python33-x64/python.exe ./build.sh"

	+ ``build.sh`` will build the whole thing, and ``deploy.sh`` will copy the needed libraries and built things to the ``SublimeCodeIntel`` repository.


Repositories
============

Most of the repositories in ``SublimeCodeIntel/src`` come from openkomodo SVN repository at ``http://svn.openkomodo.com/repos/openkomodo/trunk``

Generally, in our fork of these repositories, there are branches ``master``, ``svn``, ``pep8``, ``patched`` and ``patched-pep8``, ``py3``:

* Branch ``svn`` is the one updated directly from Open Komodo's SVN (updated when ``svn-rebase.sh`` is run)

* Branch ``pep8`` is ``svn`` + ``autopep8 -virj 0 .``

* Branch ``patched`` is ``svn`` + all relevant Open Komodo patches.

* Branch ``patched-pep8`` is ``patched`` + ``autopep8 -virj 0 .``

* Branch ``master`` is ``patched-pep8`` + SublimeCodeIntel patches.

* Branch ``py3`` is a python-modernized ``master``.


Tools
=====

There are a few tools to help fetching and maintaining updated the codebase of SublimeCodeIntel:

* ``svn-clone.sh`` makes clones from SVN repositories (as a reference of how the repositories were built, in case it's ever needed again)

* ``svn-rebase.sh`` is the one which actual upgrades stuff from the SVN, cleans the code, applies patches and so on.


Open Komodo Patches
===================

There are three sets of patches in Open Komodo:

* The ones in the repository ``patches`` in the ``/`` directory (which come from ``http://svn.openkomodo.com/repos/openkomodo/trunk/contrib/patches``). These are for several modules, but they all have already been applied by the Open Komodo team to the official SVN repository.

* The ones in the repository ``patches`` in the directory ``/scintilla``. These are all for scintilla and need to be applied during the building of Code Intel dependencies

* The ones in the repository ``codeintel`` in the directory ``/src/patches``. These are all to convert cElementTree to ``ciElementTree`` (a more efficient version of ``cElementTree``)


Build Process
=============

The repository ``codeintel``, within SublimeCodeIntel's repositories, is the heart of CodeIntel2.


Libraries/Modules
-----------------
SublimeCodeIntel requires a lot of libraries/modules from Open Komodo to work.


Open Komodo's official repository with codeintel2 source:

	[http://svn.openkomodo.com/repos/openkomodo/trunk/src/codeintel/lib/codeintel2/]


The following are in C/C++ and need to be compiled:

* ``silvercity``: Used by CodeIntel2 to parse the user's source code in most (if not all) languages, like CSS/Python/JavaScript/Ruby/etc.

* ``scintilla``: Library used by ``SilverCity``. This library is the one which actually does the heavy lifting and parsing of all user's source code. (it's patched to add User Language Definitions and XML, using 210 instead
of the older bundled version with SilverCity)

* ``pcre``: Library used by Scintilla (and should be linked statically to avoid version problems in linux and other systems)

* ``cElementTree``: (the patched, more efficient version of ``cElementTree``). Module used to parse some user's source code in some languages, like HTML/XML.

* ``ciElementTree``: Module used to read the symbol catalogs, which all are XML files with the extension ``.cix``. It's the same as the above cElementTree, but patched to be ciElementTree (to add Komodo CodeIntel2 specific features)

* ``sgmlop``: Module used by ``elementtree`` and ``HTMLTreeParser`` (it's patched to have '%' symbol as PI and send positions to Parsers)


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

* ``chardet``: Module used by ``textinfo`` (not included in the Open Komodo official repository). This is used to detect the encoding of the text being passed to CodeIntel2 if no encoding is provided. Universal Encoding Detector (chardet, GNU LGPL): [http://chardet.feedparser.org/]

* ``smallstuff``: Some of the modules in here were collected from other sources and were also not included in the Open Komodo official repository, but are also used.

* ``elementtree``: (it's patched to have "iElementTree" features in the pure python version
	of ElementTree. Not really needed if using ciElementTree)

* Other used files scattered in the sources of Open Komodo (and placed inside more4sublime):
	- ``libs/*.py``: Created by Kronuz for cross platform imports
	- ``styles.py``: ``/openkomodo/src/schemes/styles.py``
	- ``chromereg.py``: ``/openkomodo/src/sdk//pylib/chromereg.py`` (used by the UDL build process)


Other files needed during the build process:

* ``udl``: Lexers (codeintel2/lexers) from User Defined Languages (UDLs). Compiled using::

	find udl -name '*-mainlex.udl' -exec python luddite.py just_compile {} \;

* ``scintilla`` needs the interface header files. which is generated by running ``HFacer.py`` in the ``scintilla/include`` directory::
	cd scintilla/include && HFacer.py

* ``SilverCity`` needs ``ScintillaConstants.py``, which is generated by running ``write_scintilla.py`` in the ``silvercity/PySilverCity/Src`` directory::

	cd build/silvercity/PySilverCity/Src && python write_scintilla.py ../../../scintilla/include/ ../../../scintilla/include/Scintilla.iface ../SilverCity/ScintillaConstants.py
