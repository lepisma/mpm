import click
from pathlib import Path
from mpm import Store

# Start working from current directory
store = Store(Path.cwd())


@click.group()
def cli():
    """
    Music package manager (mpm)
    """
    pass


@cli.command("add", help="Add a source")
@click.argument("handler", nargs=1)
@click.argument("url", nargs=1)
def add(handler, url):
    pass


@cli.command("list", help="List currently used sources")
def list():
    pass


@cli.command("remove", help="Remove source")
def remove():
    pass


@cli.command("update", help="Update db from sources")
def update():
    pass


@cli.command("download", help="Download files")
def download():
    pass


@cli.command("import", help="Import to beets, use --clean to remove files")
@click.option("--clean", is_flag=True)
def beet_import(clean):
    pass


@cli.command("clean", help="Remove files not in db")
def clean():
    pass
