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


class RowConfig(BaseModel):
    start: int
    stop: int | None


class Sprig(BaseModel):
    _id: UUID4
    name: str
    storage: Storage
    structure: Structure
    read_config: RowConfig  # FIXME


# TODO: Decorator for grabbing metadata from read call
# TODO: Add support for tracking callsite
def tracked(func):
    def wrapper(*args, **kwargs):
        # FIXME: do something less silly here
        sprig: Sprig = args[0]
        with open(f"./sprigs/{sprig.name}.sprig", "w") as f:
            print(sprig.model_dump_json(), file=f)
        func(*args, **kwargs)

    return wrapper


@tracked
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


def read(sprig: Sprig):
    match sprig.structure:
        case Structure.ROWS:
            read_rows(sprig, start=sprig.read_config.start, stop=sprig.read_config.stop)
        case _:
            raise RuntimeError("Explode!")


def main():
    sprig = Sprig(
        _id=uuid4(),
        name="demo-sprig",
        structure=Structure.ROWS,
        read_config=RowConfig(start=0, stop=None),
        storage=LocalStorage(path="./example-data/my-dataset.csv"),
    )
    print(f"Here is your sprig: {sprig}")
    print(read(sprig))


if __name__ == "__main__":
    main()
