"""
Core types, primarily for use in the client.
"""
from abc import ABC
from dataclasses import dataclass
from enum import Enum
from typing import ClassVar, TypeAlias, Union

import pandas as pd
import pyarrow as pa
from pydantic import BaseModel


class Structure(Enum):
    TABLE = "table"
    BLOB = "blob"


class Format(ABC, BaseModel):
    structure: ClassVar[Structure]


class CSV(Format):
    structure = Structure.TABLE


class SQL(Format):
    structure = Structure.TABLE


TableFormat: TypeAlias = Union[CSV, SQL]


class LocalStorageConfig(BaseModel):
    path: str


class DatabaseStorageConfig(BaseModel):
    connection_string: str  # FIXME: Need to handle secrets, etc properly.
    query: str


class DataConfig(BaseModel):
    pass


class TableConfig(DataConfig):
    format: CSV | SQL
    start: int
    stop: int | None


class Sprig(BaseModel):
    name: str
    storage: LocalStorageConfig | DatabaseStorageConfig
    config: TableConfig


@dataclass
class Table:
    _table: pa.Table  # type: ignore

    def to_pandas(self) -> pd.DataFrame:
        return self._table.to_pandas()

    @classmethod
    def from_pandas(cls, df: pd.DataFrame) -> "Table":
        return cls(pa.Table.from_pandas(df))
