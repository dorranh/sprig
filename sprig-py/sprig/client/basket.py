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

from sprig.model import Rows


class LocalBasket:
    """"""

    def read_sprig_rows(self, name: str) -> Rows:
        # Call the CLI and get the arrow ipc stream it outputs
        stream = subprocess.Popen(
            f"sprig --name {name}", shell=True, stdout=subprocess.PIPE
        )
        reader = ipc.open_stream(stream.stdout)
        data = reader.read_all()
        return Rows(data)
