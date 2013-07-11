This repository is used to upgrade OpenKomodo codebase and to build and deploy `SublimeCodeIntel <https://github.com/SublimeCodeIntel/SublimeCodeIntel/>`_.

	* ``SublimeCodeIntel`` directory (as submodule) contains the deployed plugin.

	* ``src`` contains the sources (as submodules) and the upgrading/building/deployment scripts.


Make sure to fetch all the code dependencies by running: ``git submodule update --init --recursive``.

For pulling new stuff, use: ``git pull --recurse-submodules``.
