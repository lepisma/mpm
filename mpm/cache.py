"""
Youtube caching module
"""

from pathlib import Path
from threading import Lock, Thread
import pafy


class YtCache:

    def __init__(self, cache_path: Path, limit: int):
        self.cache_path = cache_path
        self.limit = limit
        self.cached = [[f.name, f.stat().st_mtime] for f in self.cache_path.glob("*")]
        self.list_lock = Lock()

    def _update_list(self, file_path: Path):
        self.cached.append([file_path.name, file_path.stat().st_mtime])

    def get(self, yt_id: str, stream=True):
        """
        When file is present, return file link and ignore stream flag
        """

        file_path = self.cache_path.joinpath(yt_id)

        if yt_id in [fid[0] for fid in self.cached]:
            return file_path
        else:
            audio_stream = pafy.new(yt_id).getbestaudio()
            if stream:
                # Download in a separate thread
                Thread(target=self._download, args=(audio_stream, file_path)).start()
                return audio_stream.url_https
            else:
                # Blocking download
                return file_path

    def _download(self, pafy_stream, file_path: Path):
        """
        Download given id
        """

        pafy_stream.download(str(file_path), quiet=True)

        # Update the list
        with self.list_lock:
            self._update_list(file_path)
