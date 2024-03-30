from typing import BinaryIO

from pydantic import BaseModel

from sprig.model import LocalStorageConfig


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
