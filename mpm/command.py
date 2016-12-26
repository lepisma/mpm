"""
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
"""

from .mpm import Mpm
from docopt import docopt
from pathlib import Path

# Start working from current directory
mpm = Mpm(Path.cwd())


def cli():
    """
    Main entry point for cli
    """

    arguments = docopt(__doc__, version="mpm v0.1.0")

    if arguments["add"]:
        mpm.add(arguments["<resolver>"], arguments["<name>"],
                arguments["<url>"], arguments["--inc"])
    elif arguments["ls"] or arguments["list"]:
        mpm.list()
    elif arguments["up"] or arguments["update"]:
        mpm.update()
    elif arguments["dl"] or arguments["download"]:
        mpm.download()
