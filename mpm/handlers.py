"""
Handle source to list conversion
"""


def youtube():
    """
    """

    print("i am jutube")


def get_handler(identifier):
    """
    Return handler by string
    """

    handler = globals().get(identifier)

    if handler:
        return handler
    else:
        raise NotImplementedError(identifier + " handler not implemented")
