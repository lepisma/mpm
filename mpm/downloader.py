"""
Handle downloading and tagging
"""

from colorama import Fore, init
from multiprocessing import Pool
from subprocess import run
from tqdm import tqdm

init(autoreset=True)


def _download_process(yid):
    """
    Helper downloader
    """

    cmd = [
        "youtube-dl", "-x", "-w", "-q", "--no-warnings", "--audio-format",
        "mp3", "--audio-quality", "0", "--prefer-ffmpeg"
    ]
    cmd.append("https://www.youtube.com/watch?v=" + yid)
    run(cmd)


def download(db):
    """
    Download file from db
    """

    download_ids = []
    for idx, item in enumerate(db.items):
        if item["download"]:
            download_ids.append(idx)

    print(Fore.BLUE + "Downloading " + str(len(download_ids)) + " items")

    progressbar = tqdm(total=len(download_ids))

    pool = Pool(processes=5)
    for _ in pool.imap_unordered(
            _download_process, [db.items[idx]["yid"] for idx in download_ids]):
        progressbar.update()

    # Mark items
    for item in enumerate(db.items):
        item["download"] = False
