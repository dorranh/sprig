from abc import ABC
from contextlib import contextmanager
from typing import BinaryIO

from pydantic import BaseModel
from sqlalchemy import create_engine, text

from sprig.model import DatabaseStorageConfig, LocalStorageConfig


class ReadOnly(ABC, BaseModel):
    """Abstract base class for storage types which are read only"""

    pass


class ReadWrite(ABC, BaseModel):
    """Abstract base class for storage types which may be both read from and written to"""

    pass


class LocalStorage(ReadWrite):
    config: LocalStorageConfig

    def open(self) -> BinaryIO:
        return open(self.config.path, "rb")

    def open_for_write(self) -> BinaryIO:
        return open(self.config.path, "wb")


class SQLStorage(ReadOnly):
    config: DatabaseStorageConfig

    @contextmanager
    def open(self):  # TODO: Type annotation
        engine = create_engine(self.config.connection_string)
        connection = engine.connect()
        cursor = connection.execute(text(self.config.query))
        yield cursor
        connection.close()
