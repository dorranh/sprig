"""
Core types, primarily for use in the client.
"""
from dataclasses import dataclass
from enum import Enum

import pandas as pd
from pyarrow import Table
from pydantic import BaseModel
from pydantic.types import UUID4


class Structure(Enum):
    ROWS = "rows"
    COLUMNS = "columns"
    BLOB = "blob"


class Format(Enum):
    CSV = "csv"
    SQL = "sql"

class StorageConfig(BaseModel):
    pass


class LocalStorageConfig(StorageConfig):
    path: str

class DatabaseStorageConfig(StorageConfig):
    connection_string: str # FIXME: Need to handle secrets, etc properly.
    query: str

class RowConfig(BaseModel):
    start: int
    stop: int | None


class Sprig(BaseModel):
    id: UUID4
    name: str
    storage: LocalStorageConfig | DatabaseStorageConfig
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
