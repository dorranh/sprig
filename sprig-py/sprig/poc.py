from enum import Enum
from uuid import uuid4
from pydantic import BaseModel
from pydantic.types import UUID4

from typing import TextIO


class Structure(Enum):
    ROWS = "rows"
    COLUMNS = "columns"
    BLOB = "blob"


class Format(Enum):
    CSV = "csv"


class StorageConfig:
    pass


class Storage(BaseModel):
    def open(self) -> TextIO:  # FIXME: This should probably be BytesIO instead
        ...


class LocalStorage(Storage):
    path: str

    def open(self):
        return open(self.path)


class Sprig(BaseModel):
    _id: UUID4
    name: str
    storage: Storage


def read_rows(sprig: Sprig, start: int = 0, stop: int | None = None):
    stream = sprig.storage.open()
    # FIXME - Just for prototyping I am loading everything into memory
    lines = [l.rstrip("\n") for l in stream.readlines()]
    # This is my own stupid csv parser. Let's add a more robust one in the future,
    #   most likely pyarrow
    if stop is not None:
        slice = lines[start:stop]
    else:
        slice = lines[start:]
    rows = []
    for x in slice:
        rows.append(x.split(","))
    return rows


def main():
    sprig = Sprig(
        _id=uuid4(),
        name="demo-sprig",
        storage=LocalStorage(path="./example-data/my-dataset.csv"),
    )
    print(f"Here is your sprig: {sprig}")
    print(read_rows(sprig))


if __name__ == "__main__":
    main()
