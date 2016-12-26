"""
Handle source to list conversion
"""

from subprocess import Popen, PIPE
from tqdm import tqdm


def youtube(name, url, db):
    """
    """

    cmd = ["youtube-dl", "--get-id", "--ignore-errors", "--no-color"]
    cmd.append(url)

    progress = tqdm(desc="Getting list of items")

    proc = Popen(cmd, bufsize=1, stdout=PIPE, stderr=PIPE)
    for line in proc.stdout:
        yid = line.decode("utf-8").strip()
        if len(yid) == 11:
            if not db.indb("youtube", name, yid):
                db.insert({
                    "handler": "youtube",
                    "source": name,
                    "yid": yid,
                    "download": True,
                    "imported": False,
                    "file": None
                })
                progress.update()
            else:
                progress.close()
                print("Reached the end of new items.\n")
                proc.kill()
    proc.stdout.close()
    proc.wait()


def get_handler(identifier):
    """
    Return handler by string
    """

    handler = globals().get(identifier)

    if handler:
        return handler
    else:
        raise NotImplementedError(identifier + " handler not implemented")
