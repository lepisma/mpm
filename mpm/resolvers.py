"""
Handle source to list conversion
"""


def youtube(source, links):
    """
    Resolve youtube playlists
    """

    if source["url"] in links:
        return []
    else:
        return [source["url"]]


def get_resolver(identifier):
    """
    Return handler by string
    """

    resolver = globals().get(identifier)

    if resolver:
        return resolver
    else:
        raise NotImplementedError
