"""
Music package manager (mpm)

Usage:
  mpm add youtube <name> <url>
  mpm ls | list
  mpm up | update
  mpm dl | download
  mpm im | import [--clean]

  mpm -h | --help
  mpm -v | --version

Arguments:
  add            Add source.
  ls, list       List available sources.
  up, update     Update items in db.
  dl, download   Download files.
  im, import     Import to beets.

Options:
  -h, --help     Show this screen.
  -v, --version  Show version.
  --clean        Clean after import.
"""

from .mpm import Store
from docopt import docopt
from pathlib import Path

# Start working from current directory
store = Store(Path.cwd())


def cli():
    """
    Main entry point for cli
    """

    arguments = docopt(__doc__, version="mpm v0.1.0")

    if arguments["add"]:
        # Assuming youtube by default as of now
        store.add("youtube", arguments["<name>"], arguments["<url>"])
    elif arguments["ls"] or arguments["list"]:
        store.list()
    elif arguments["up"] or arguments["update"]:
        store.update()
    elif arguments["dl"] or arguments["download"]:
        store.download()
    elif arguments["im"] or arguments["import"]:
        store.beet_import()
