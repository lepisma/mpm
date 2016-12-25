"""
Music package manager (mpm)

Usage:
  mpm add youtube <url>
  mpm ls | list
  mpm rm | remove
  mpm up | update
  mpm dl | download
  mpm import [--clean]

  mpm -h | --help
  mpm -v | --version

Arguments:
  add           Add source.
  ls, list       List available sources.
  rm, remove     Remove a source.
  up, update     Update items in db.
  dl, download   Download files.
  import        Import to beets.

Options:
  -h, --help     Show this screen.
  -v, --version  Show version.
  --clean       Clean after import.
"""

from pathlib import Path
from mpm import Store
from docopt import docopt

# Start working from current directory
store = Store(Path.cwd())


def cli():
    """
    Main entry point for cli
    """

    arguments = docopt(__doc__, version="mpm v0.1.0")
