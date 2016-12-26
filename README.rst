=============================
mpm
=============================

Music package manager.

Right now its just a simple convenience wrapper around `youtube-dl <https://rg3.github.io/youtube-dl/>`_. The idea is to create a set of *sources* which resolve to youtube links. The resolution part is planned to include suggestions, hot-right-now songs and other ideas to ease music exploration.

.. code-block::

  Music package manager (mpm)

  Usage:
    mpm add <resolver> <name> <url> [--inc]
    mpm ls | list
    mpm up | update
    mpm dl | download

    mpm -h | --help
    mpm -v | --version

  Arguments:
    add            Add source.
    ls, list       List available sources.
    up, update     Update items in db.
    dl, download   Download files.

  Options:
    -h, --help     Show this screen.
    -v, --version  Show version.
    --inc          Incremental source.
