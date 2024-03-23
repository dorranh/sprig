import click
import pandas as pd
from dataclasses import dataclass
from enum import Enum
from uuid import uuid4
from pydantic import BaseModel
from pydantic.types import UUID4
from pyarrow import Table, csv, ipc
import subprocess
import yaml

from typing import NewType, BinaryIO, Tuple
import glob
import os

from sprig.app.access import Access
from sprig.app.io import read


@click.command()
@click.option("--name", required=True)
def cli(name: str):
    """Mock-up of the sprig executable

    Returns a stream (to stdout) containing the sprig's contents
    """
    # TODO: This could be configured as remote or local
    access = Access()

    # TODO: Fail gracefully here
    sprig = access.get_sprig(name)

    # TODO: Might want to be doing a streaming read instead
    data = read(sprig)

    stdout = click.get_binary_stream("stdout")
    writer = ipc.new_stream(stdout, data._table.schema)
    writer.write(data._table)  # TODO: Do we want to use write_table() instead?
    writer.close()
