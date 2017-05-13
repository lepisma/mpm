"""
Music package manager (mpm)

Usage:
  mpm source add <resolver> <name> <url> [--inc]
  mpm source (rm | remove) <name>
  mpm source (ls | list)
  mpm source (up | update) [<name>]
  mpm (ls | list) <query>
  mpm play <query>

  mpm -h | --help
  mpm -v | --version

Options:
  -h, --help     Show this screen.
  -v, --version  Show version.
  --inc          Incremental source. Handled as special case by resolver.
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

    if arguments["source"]

    if arguments["add"]:
        mpm.add(arguments["<resolver>"], arguments["<name>"],
                arguments["<url>"], arguments["--inc"])
    elif arguments["ls"] or arguments["list"]:
        mpm.list()
    elif arguments["up"] or arguments["update"]:
        mpm.update()
