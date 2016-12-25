"""
Main mpm module
"""

import yaml
from pathlib import Path
from clint.textui import colored, puts


class Sources:
    """
    Sources file wrapper
    """

    def __init__(self, sources_path):

        self.sources_path = sources_path
        self.sources_dict = self._read_sources()

    def _read_sources(self):
        """
        Return sources dictionary
        Create file if none found
        """

        if not self.sources_path.is_file():
            puts(colored.yellow("Sources file not found, creating..."))
            self.sources_path.touch()

        with self.sources_path.open() as fi:
            self.sources_dict = yaml.load(fi)

    def list(self):
        """
        Return list of all source items
        """

        print(self.sources_dict)

    def add(self, handler, uri):
        """
        Add given source item to file
        """

        pass

    def _commit_sources(self):
        """
        Write to file
        """

        with self.sources_path.open("w") as fo:
            yaml.dump(self.sources_dict, fo)


class DB:
    """
    DB wrapper
    """

    def __init__(self, db_path):
        """
        """

        self.db_path = Path(db_path)
        self.db = self._get_db()

    def _get_db(self):
        """
        Return db
        Create if none found
        """

        if not self.db_path.is_file():
            puts(colored.yellow("DB not found, creating..."))
            self.db_path.touch()

    def prune(self, imported=False):
        """
        Remove files not in
        Optionally remove imported files and tag for dl
        """

        pass


class Store:
    """
    Store for mpm data
    """

    def __init__(self, directory):

        self.directory = Path(directory)
        self.sources = Sources(self.directory.joinpath("mpm.yaml"))
        self.db = DB(self.directory.joinpath("mpm-db.json"))

    def update(self):
        """
        Update lock file using sources
        """

        pass

    def download(self):
        """
        Download marked files
        """

        pass

    def beet_import(self):
        """
        Run beet import on unimported files
        """

        pass
