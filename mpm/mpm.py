"""
Main mpm module
"""

from .resolvers import get_resolver
from colorama import init, Fore
from pathlib import Path
from tqdm import tqdm
import sys
import yaml

init(autoreset=True)


class Mpm:
    """
    Main store for mpm data
    """

    def __init__(self, directory):

        self.directory = Path(directory)
        self.sources_path = self.directory.joinpath("mpm.yaml")
        self.links_path = self.directory.joinpath("mpm.links")

        self._read_sources()
        self._read_links()

    def _read_links(self):
        """
        Read links list
        """

        if not self.links_path.is_file():
            print(Fore.YELLOW + "Links file not found, creating...")
            self.links_path.touch()

        with self.links_path.open() as fi:
            self.links = fi.readlines()

    def _write_links(self):
        """
        Write links to file
        """

        with self.links_path.open("w") as fo:
            fo.write("\n".join(self.links))

    def _read_sources(self):
        """
        Read source dictionary
        Create file if none found
        """

        if not self.sources_path.is_file():
            print(Fore.YELLOW + "Sources file not found, creating...")
            self.sources = {}
            self._write_sources()

        with self.sources_path.open() as fi:
            self.sources = yaml.load(fi)

    def _write_sources(self):
        """
        Write source dictionary to file
        """

        with self.sources_path.open("w") as fo:
            yaml.dump(self.sources, fo)

    def update(self):
        """
        Update lock file using sources
        """

        for resolver, sources in self.sources.items():
            for source in sources:
                print(Fore.BLUE + "Updating " + source["name"] + " (" +
                      resolver + ")")
                self.links += get_resolver(resolver)(source, self.links)
                self._write_links()

    def add(self, resolver_name, source_name, url, inc):
        """
        Add source
        """

        # Check if resolver is implemented
        try:
            get_resolver(resolver_name)
        except NotImplementedError:
            print(Fore.RED + resolver_name +
                  " resolver not implemented, aborting.")
            sys.exit(1)

        if resolver_name not in self.sources:
            self.sources[resolver_name] = []

        if url in [item["url"] for item in self.sources[resolver_name]]:
            print(Fore.RED + "Url already present. Skipping.")
        elif source_name in [
                item["name"] for item in self.sources[resolver_name]
        ]:
            print(Fore.RED + "Source already present. Skipping.")
        else:
            self.sources[resolver_name].append({
                "name": source_name,
                "url": url,
                "inc": inc
            })
            self._write_sources()

    def list(self):
        """
        List items in sources list
        """

        print("Listing sources from ", end="")
        print(Fore.YELLOW + str(self.sources_path))

        for resolver, sources in self.sources.items():
            for source in sources:
                print("[", end="")
                print(Fore.BLUE + resolver, end="")
                if source["inc"]:
                    print(Fore.BLUE + " (inc)", end="")
                print("] :: " + source["name"] + " :: " + source["url"])
