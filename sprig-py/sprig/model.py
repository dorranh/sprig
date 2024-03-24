"""
Core types, primarily for use in the client.
"""
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


class Structure(Enum):
    ROWS = "rows"
    COLUMNS = "columns"
    BLOB = "blob"


class Format(Enum):
    CSV = "csv"


class StorageConfig(BaseModel):
    pass


class LocalStorageConfig(StorageConfig):
    path: str


class RowConfig(BaseModel):
    start: int
    stop: int | None


class Sprig(BaseModel):
    id: UUID4
    name: str
    # FIXME: Using single concrete subtype rather than a union or parent here
    storage: LocalStorageConfig
    structure: Structure
    format: Format
    read_config: RowConfig  # TODO: Add other config here


@dataclass
class Rows:
    _table: Table  # type: ignore

    def to_pandas(self) -> pd.DataFrame:
        return self._table.to_pandas()

    @classmethod
    def from_pandas(cls, df: pd.DataFrame) -> "Rows":
        return cls(Table.from_pandas(df))
