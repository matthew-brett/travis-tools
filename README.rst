##########################################
Shell utilities for working with travis-ci
##########################################

In your test matrix, define variables:

* ``DEPENDS`` (optional) - list of packages that should be installed by pip before
  building. Default is empty.
* ``INSTALL_TYPE`` (optional) - one of: ``setup`` (``python setup.py install``); ``sdist``
  (install from sdist);  ``wheel`` (build wheel and install from wheel);
  ``requirements`` (install dependencies from ``reqirements.txt``);
  ``pip-devel`` (install with ``pip install -e .``).  Default (empty) is
  ``pip-devel``.
* EXTRA_PIP_ARGS (optional) - any extra arguments to pass to pip.
* COVERAGE (optional) - if not empty, install and run coverage, coveralls.


See: https://github.com/nipy/nipy/blob/master/.travis.yml for an example.
