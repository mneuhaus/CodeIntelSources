Generally, in these repositories, there are branches `master`, `svn`, `pep8`, `patched` and `patched-pep8`, `py3`.

* Branch `svn` is the one updated directly from OpenKomodo's SVN (updated when svn-rebase.sh is run)

* Branch `pep8` is `svn` + `autopep8 -virj 0 .`

* Branch `patched` is `svn` + all relevant OpenKomodo patches.

* Branch `patched-pep8` is `patched` + `autopep8 -virj 0 .`

* Branch `master` is `patched-pep8` + SublimeCodeIntel patches.

* Branch `py3` is python-modernized `master`.


`svn-clone.sh` makes clones from SVN repositories (in case it's ever needed)

`svn-rebase.sh` is the one which actuall upgrades stuff from the SVN and cleans the code, applies patches and so on.
