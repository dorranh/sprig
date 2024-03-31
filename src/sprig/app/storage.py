from contextlib import contextmanager
from typing import BinaryIO

from pydantic import BaseModel
from sqlalchemy import create_engine, text

from sprig.model import DatabaseStorageConfig, LocalStorageConfig


class Storage(BaseModel):
    def open(self) -> BinaryIO:
        ...

    def open_for_write(self) -> BinaryIO:
        ...


class LocalStorage(Storage):
    info: LocalStorageConfig

    def open(self) -> BinaryIO:
        return open(self.info.path, "rb")

    def open_for_write(self) -> BinaryIO:
        return open(self.info.path, "wb")


class SQLStorage(BaseModel):
    config: DatabaseStorageConfig

    @contextmanager
    def open(self):  # TODO: Type annotation
        engine = create_engine(self.config.connection_string)
        connection = engine.connect()
        cursor = connection.execute(text(self.config.query))
        yield cursor
        connection.close()
