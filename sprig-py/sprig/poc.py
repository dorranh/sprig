import pandas as pd
from dataclasses import dataclass
from enum import Enum
from uuid import uuid4
from pydantic import BaseModel
from pydantic.types import UUID4
from pyarrow import Table, csv

from typing import NewType, BinaryIO
import glob
import os


class Structure(Enum):
    ROWS = "rows"
    COLUMNS = "columns"
    BLOB = "blob"


class Format(Enum):
    CSV = "csv"


class StorageConfig:
    pass


class Storage(BaseModel):
    def open(self) -> BinaryIO:  # FIXME: This should probably be BytesIO instead
        ...


class LocalStorage(Storage):
    path: str

    def open(self):
        return open(self.path, "rb")


class RowConfig(BaseModel):
    start: int
    stop: int | None


class Sprig(BaseModel):
    _id: UUID4
    name: str
    storage: LocalStorage  # This does not serialize as the subtype
    structure: Structure
    format: Format
    read_config: RowConfig  # FIXME


# TODO: Decorator for grabbing metadata from read call
# TODO: Add support for tracking callsite
def tracked(func):
    def wrapper(*args, **kwargs):
        # FIXME: do something less silly here
        sprig: Sprig = args[0]
        with open(f"./sprigs/{sprig.name}.sprig", "w") as f:
            print(sprig.model_dump_json(), file=f)
        return func(*args, **kwargs)

    return wrapper


# Note: This is the integration layer for sprig data to the types you want to use
# in your analysis, 3rd party libs, etc.


@dataclass
class Rows:
    _table: Table  # type: ignore

    def to_pandas(self) -> pd.DataFrame:
        return self._table.to_pandas()


@tracked
def read_rows(sprig: Sprig, start: int = 0, stop: int | None = None) -> Rows:
    match sprig.format:
        case Format.CSV:
            # FIXME: Check for format for csv vs avro etc. Right now we are only
            # parsing CSV files.
            stream = sprig.storage.open()
            # FIXME: This loads the whole thing into memory
            table: Table = csv.read_csv(stream)
            return Rows(table.slice(start, stop))
        case _:
            raise RuntimeError(f"Unsupported format: {sprig.format}")


def read(sprig: Sprig) -> Rows:  # TODO: Add other return types
    match sprig.structure:
        case Structure.ROWS:
            return read_rows(
                sprig, start=sprig.read_config.start, stop=sprig.read_config.stop
            )
        case _:
            raise RuntimeError("Explode!")


class Basket:
    """Methods for managing / reading sprigs"""

    def list_sprigs(self) -> list[str]:
        files = glob.glob("./sprigs/*.sprig")
        return [os.path.basename(os.path.splitext(f)[0]) for f in files]

    def get_sprig(self, name: str) -> Sprig:
        with open(f"sprigs/{name}.sprig") as f:
            return Sprig.model_validate_json(f.read())


def main():
    # In this example we CREATE a sprig
    sprig = Sprig(
        _id=uuid4(),
        name="demo-sprig",
        structure=Structure.ROWS,
        format=Format.CSV,
        read_config=RowConfig(start=0, stop=None),
        storage=LocalStorage(path="./example-data/my-dataset.csv"),
    )
    print(f"Here is your sprig: {sprig}")
    print(read(sprig).to_pandas())

    print()
    print("Sprigs in the basket:")
    print(Basket().list_sprigs())
    # TODO: Workflow for reading existing sprigs

    my_analysis()


def my_analysis():
    sprig = Basket().get_sprig("demo-sprig")
    print(sprig)
    print(read(sprig).to_pandas())


if __name__ == "__main__":
    main()
