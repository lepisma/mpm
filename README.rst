=============================
mpm
=============================

Music package manager.

Right now its just a simple convenience wrapper around `youtube-dl <https://rg3.github.io/youtube-dl/>`_. The idea is to create a set of *sources* which resolve to youtube links. The resolution part is planned to include suggestions, hot-right-now songs and other ideas to ease music exploration.

  **Change of plans**: It would probably end up becoming a streaming / cached type music manager. Maybe a beets plugin with a FUSE layer over streaming media sources. This would help me do everything acoustic / recommendation / exploration without loosing content / disk space.

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
