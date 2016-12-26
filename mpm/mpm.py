"""
Main mpm module
"""

from .resolvers import get_resolver
from colorama import init, Fore
from pathlib import Path
from subprocess import run
from multiprocessing import JoinableQueue, Pool
from tqdm import tqdm
import sys
import yaml
import youtube_dl

init(autoreset=True)


def convert_audio(queue):
    """
    Convert audio to mp3 using ffmpeg
    """

    while True:
        file_name = queue.get()
        output_name = str(Path(file_name).with_suffix(".mp3"))
        cmd = [
            "ffmpeg", "-i", file_name, "-b:a", "192k", "-nostats", "-loglevel",
            "0", output_name
        ]
        run(cmd)
        queue.task_done()
        Path(file_name).unlink()


class DownloadLogger:
    def debug(self, msg):
        pass

    def warning(self, msg):
        pass

    def error(self, msg):
        pass


class Mpm:
    """
    Main store for mpm data
    """

    def __init__(self, directory):

        self.directory = Path(directory)
        self.sources_path = self.directory.joinpath("mpm.yaml")
        self.links_path = self.directory.joinpath("mpm.links")
        self.archive_path = self.directory.joinpath("mpm.lock")

        self.converted_processes = []

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
        Write source dictioanry to file
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

    def download(self):
        """
        Download links
        """

        queue = JoinableQueue()
        Pool(5, convert_audio, (queue, ))

        progress = tqdm(desc="Downloading files")

        def _hook(args):
            """
            youtube-dl progress hook
            """

            if args["status"] == "finished":
                queue.put(args["filename"])
                progress.update()

        downloader = "aria2c"
        downloader_opts = ["-q"]

        ydl_opts = {
            "quiet": True,
            "no_warnings": True,
            "ignoreerrors": True,
            "download_archive": str(self.archive_path),
            "format": "bestaudio/best",
            "external_downloader": downloader,
            "external_downloader_args": downloader_opts,
            "progress_hooks": [_hook],
            "logger": DownloadLogger()
        }

        with youtube_dl.YoutubeDL(ydl_opts) as ydl:
            ydl.download(self.links)

        queue.join()
        progress.close()

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
