import click

from pyarrow import ipc
import json

from sprig.app.repo import LocalRepo
from sprig.app import io
from sprig.app.storage import LocalStorage
from sprig.model import LocalStorageConfig, Rows


@click.group()
def cli():
    pass


@cli.command()
@click.option("--name", required=True)
def read(name: str):
    """Mock-up of the sprig executable

    Returns a stream (to stdout) containing the sprig's contents
    """
    # TODO: Make this configurable
    repo = LocalRepo()

    # TODO: Fail gracefully here
    sprig = repo.get_sprig(name)

    # TODO: Might want to be doing a streaming read instead
    data = io.read(sprig)

    stdout = click.get_binary_stream("stdout")
    writer = ipc.new_stream(stdout, data._table.schema)
    writer.write(data._table)  # TODO: Do we want to use write_table() instead?
    writer.close()


@cli.command()
def list():
    """List available sprigs"""
    # TODO: Make this configurable
    repo = LocalRepo()
    stdout = click.get_binary_stream("stdout")
    # FIXME: Use an actual schema here
    stdout.write(json.dumps({"sprigs": repo.list_sprigs()}).encode())


@cli.command()
@click.option("--name", required=True)
def get(name: str):
    """Get a sprig by name"""
    # TODO: Make this configurable
    repo = LocalRepo()
    # TODO: Fail gracefully here
    sprig = repo.get_sprig(name)

    stdout = click.get_binary_stream("stdout")
    stdout.write(sprig.model_dump_json().encode())


@cli.command()
@click.option("--name", required=True)
@click.option("--path", required=True)
# FIXME: This currently only supports local storage. Need to accept a wider
# range of args.
# FIXME: Add arg for format, etc.
def create(name: str, path: str):
    """Constructs a new sprig from the data passed via stdin"""
    # TODO: Make this configurable
    repo = LocalRepo()

    stdin = click.get_binary_stream("stdin")
    stdout = click.get_binary_stream("stdout")

    reader = ipc.open_stream(stdin)
    table = reader.read_all()

    sprig = io.sprig_from_rows(
        name=name,
        rows=Rows(table),
        storage=LocalStorage(info=LocalStorageConfig(path=path)),
    )

    stdout.write(sprig.model_dump_json().encode())
