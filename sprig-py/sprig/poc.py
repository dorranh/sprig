import click
import pandas as pd
from dataclasses import dataclass
from enum import Enum
from uuid import uuid4
from pydantic import BaseModel
from pydantic.types import UUID4
from pyarrow import Table, csv, ipc
import subprocess

from typing import NewType, BinaryIO, Tuple
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
    def open(self) -> BinaryIO:
        ...

    def open_for_write(self) -> BinaryIO:
        ...


class LocalStorage(Storage):
    path: str

    def open(self):
        return open(self.path, "rb")

    def open_for_write(self) -> BinaryIO:
        return open(self.path, "wb")


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

    @classmethod
    def from_rows(
        cls, name: str, rows: "Rows", storage: LocalStorage, format: Format = Format.CSV
    ) -> "Sprig":
        # Write the sprig
        # TODO [Dorran] Pick back up here
        stream = storage.open_for_write()
        write_rows(rows, format, stream)
        stream.close()
        sprig = Sprig(
            _id=uuid4(),
            name=name,
            storage=storage,
            format=format,
            read_config=RowConfig(start=0, stop=None),
            structure=Structure.ROWS,
        )
        # FIXME: Do something cleaner here when it comes to writing out metadata
        with open(f"./sprigs/{sprig.name}.sprig", "w") as f:
            print(sprig.model_dump_json(), file=f)
        return sprig


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


def write_rows(rows: Rows, format: Format, stream: BinaryIO) -> None:
    match format:
        case Format.CSV:
            csv.write_csv(rows._table, stream)
        case _:
            raise RuntimeError(f"Unsupported format: {format}")


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


@click.command()
@click.option("--name", required=True)
def cli(name: str):
    """Mock-up of the sprig executable

    Returns a stream (to stdout) containing the sprig's contents
    """
    # TODO: This could be configured as remote or local
    basket = Basket()

    # TODO: Fail gracefully here
    sprig = basket.get_sprig(name)

    # TODO: Might want to be doing a streaming read instead
    data = read(sprig)

    stdout = click.get_binary_stream("stdout")
    writer = ipc.new_stream(stdout, data._table.schema)
    writer.write(data._table)  # TODO: Do we want to use write_table() instead?
    writer.close()


def main():
    # In this example we CREATE a sprig
    sprig = Sprig(
        _id=uuid4(),
        name="demo-sprig",
        structure=Structure.ROWS,
        format=Format.CSV,
        read_config=RowConfig(start=2, stop=None),
        storage=LocalStorage(path="./example-data/my-dataset.csv"),
    )
    print(f"Here is your sprig: {sprig}")
    print(read(sprig).to_pandas())

    print()
    print("Sprigs in the basket:")
    print(Basket().list_sprigs())
    # TODO: Workflow for reading existing sprigs

    my_analysis()

    another_analysis()

    print("Calling executable and reading its output:")
    print(LocalBasket().read_sprig_rows("demo-sprig"))
    print("DONE!")


def my_analysis():
    "Reads a pre-existing sprig"
    sprig = Basket().get_sprig("demo-sprig")
    print(sprig)
    df = read(sprig).to_pandas()
    print(df)

    # Do some stuff to the data
    df["new_column"] = 4242

    # TODO: Pick back up here
    new_sprig = Sprig.from_rows(
        "my-updated-sprig",
        Rows(Table.from_pandas(df)),
        storage=LocalStorage(path="./example-data/my-updated-data.csv"),
    )

    print(new_sprig)


def another_analysis():
    """Depends on sprig generated in my_analysis"""
    sprig = Basket().get_sprig("my-updated-sprig")
    print(sprig)
    df = read(sprig).to_pandas()
    print(df)


if __name__ == "__main__":
    main()
