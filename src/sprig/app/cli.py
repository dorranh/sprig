import json
from pathlib import Path

import click
import pyarrow as pa

from sprig.app import io
from sprig.app.repo import LocalRepo
from sprig.app.storage import LocalStorage
from sprig.model import LocalStorageConfig, Table


@click.group()
@click.option("--dir", "directory", default="sprigs", type=click.Path())
@click.pass_context
def cli(ctx, directory: str):
    ctx.obj = LocalRepo(Path(directory))


@cli.command()
@click.option("--name", required=True)
@click.pass_obj
def read(repo: LocalRepo, name: str):
    """Returns a stream (to stdout) containing the sprig's contents"""
    # TODO: Fail gracefully here
    sprig = repo.get_sprig(name)

    # TODO: Might want to be doing a streaming read instead of loading everything to a buffer
    # then passing it to stdout as a separate step
    data = io.read(sprig)

    stdout = click.get_binary_stream("stdout")
    writer = pa.ipc.new_stream(stdout, data._table.schema)
    writer.write(data._table)
    writer.close()


@cli.command()
@click.pass_obj
def list(repo: LocalRepo):
    """List available sprigs"""
    stdout = click.get_binary_stream("stdout")
    # FIXME: Use an actual schema here
    stdout.write(json.dumps({"sprigs": repo.list_sprigs()}).encode())


@cli.command()
@click.option("--name", required=True)
@click.pass_obj
def get(repo: LocalRepo, name: str):
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
@click.option("--structure")
@click.pass_obj
def create(repo: LocalRepo, name: str, path: str, structure: str = "table"):
    """
    Constructs a new sprig from the data passed via stdin, returning the new sprig via
    STDOUT.

    Currently this only supports writing to local storage at the provided --path.
    """

    stdin = click.get_binary_stream("stdin")
    stdout = click.get_binary_stream("stdout")

    reader = pa.ipc.open_stream(stdin)
    table = reader.read_all()

    match structure:
        case "table":
            sprig = io.sprig_from_table(
                sprig_dir=repo.path,
                name=name,
                rows=Table(table),
                storage=LocalStorage(config=LocalStorageConfig(path=path)),
            )
        case s:
            raise RuntimeError(f"The provided structure {s} is not yet supported for creating sprigs.")

    stdout.write(sprig.model_dump_json().encode())
