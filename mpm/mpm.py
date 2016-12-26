"""
Main mpm module
"""

from .downloader import download
from .handlers import get_handler
from colorama import init, Fore
from pathlib import Path
import yaml

init(autoreset=True)


class Sources:
    """
    Sources file wrapper
    """

    def __init__(self, sources_path):

        self.sources_path = sources_path
        self._read_sources()

    def _read_sources(self):
        """
        Return sources dictionary
        Create file if none found
        """

        if not self.sources_path.is_file():
            print(Fore.YELLOW + "Sources file not found, creating...")
            self.sources_dict = {}
            self._commit_sources()

        with self.sources_path.open() as fi:
            self.sources_dict = yaml.load(fi)

    def add(self, handler_name, source_name, url):
        """
        Add given source item to file
        """

        # Add handler key if not present
        if handler_name not in self.sources_dict:
            self.sources_dict[handler_name] = []

        if url in [item["url"] for item in self.sources_dict[handler_name]]:
            print(Fore.RED + "Url already present. Skipping.")
        elif source_name in [
                item["name"] for item in self.sources_dict[handler_name]
        ]:
            print(Fore.RED + "Source already present. Skipping.")
        else:
            self.sources_dict[handler_name].append({
                "name": source_name,
                "url": url
            })
            self._commit_sources()

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
        self._read_db()

    def _read_db(self):
        """
        Read db
        Create if none found
        """

        if not self.db_path.is_file():
            print(Fore.YELLOW + "DB not found, creating...")
            self.items = []
            self._commit_db()

        with self.db_path.open() as fi:
            self.items = yaml.load(fi)

    def insert(self, item):
        """
        Insert item in db
        """

        self.items.append(item)

    def save(self):
        self._commit_db()

    def indb(self, handler, source_name, yid):
        """
        Check if given item is in db
        """

        return [handler, source_name, yid] in [
            [item["handler"], item["source"], item["yid"]]
            for item in self.items
        ]

    def mark_dup(self):
        """
        Mark duplicates across all items to avoid download
        """

        uniques = []

        for idx, item in enumerate(self.items):
            if item["yid"] in uniques:
                item["download"] = False
            else:
                uniques.append(item["yid"])

        self._commit_db()

        print("Duplicates youtube ids marked : " + str(
            len(self.items) - len(uniques)))

    def _commit_db(self):
        """
        Write to file
        """

        with self.db_path.open("w") as fo:
            yaml.dump(self.items, fo)


class Store:
    """
    Store for mpm data
    """

    def __init__(self, directory):

        self.directory = Path(directory)
        self.sources = Sources(self.directory.joinpath("mpm.yaml"))
        self.db = DB(self.directory.joinpath("mpm-lock.yaml"))

    def update(self):
        """
        Update lock file using sources
        """

        for handler, sources in self.sources.sources_dict.items():
            for source in sources:
                print(Fore.BLUE + "Updating " + source["name"] + " (" + handler
                      + ")")
                hfun = get_handler(handler)
                hfun(source["name"], source["url"], self.db)
                self.db.save()

    def download(self):
        """
        Download marked files
        """

        self.db.mark_dup()
        download(self.db)
        self.db.save()

    def beet_import(self):
        """
        Run beet import on unimported files
        """

        pass

    def add(self, handler_name, source_name, url):
        """
        Add source
        """

        # Check if handler is implemented
        try:
            get_handler(handler_name)
        except NotImplementedError:
            print(Fore.RED + "Handler not implemented. Aborting.")

        self.sources.add(handler_name, source_name, url)

    def list(self):
        """
        List items in sources list
        """

        print("Listing sources from ", end="")
        print(Fore.YELLOW + str(self.sources.sources_path))

        for handler, sources in self.sources.sources_dict.items():
            for source in sources:
                print("[", end="")
                print(Fore.BLUE + handler, end="")
                print("] :: " + source["name"] + " :: " + source["url"])
