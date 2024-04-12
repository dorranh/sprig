"""
Utilities for performing IO such as reading a sprig's data and creating new sprigs
"""

from pathlib import Path
from typing import Any, BinaryIO, Callable, ParamSpec, TypeVar, cast

import pyarrow as pa
import yaml
from pyarrow import csv
from sqlalchemy import CursorResult

from sprig.app.storage import LocalStorage, SQLStorage
from sprig.model import (
    CSV,
    SQL,
    DatabaseStorageConfig,
    Format,
    LocalStorageConfig,
    Sprig,
    Structure,
    Table,
    TableConfig,
    TableFormat,
)


def dump_sprig(sprig_dir: Path, sprig: Sprig) -> None:
    """Writes the sprigs configuration to a .sprig file"""
    sprig_dir.mkdir(exist_ok=True)
    sprig_path = sprig_dir.joinpath(f"{sprig.name}.sprig")
    with sprig_path.open("w") as f:
        print(yaml.dump(sprig.model_dump(mode="json")), file=f)


def sprig_from_table(
    sprig_dir: Path, name: str, rows: "Table", storage: LocalStorage, format: TableFormat = CSV()
) -> "Sprig":
    """
    Constructs a new Sprig from an in-memory table, writing the correpsonding table data to the
    provide storage and writing the new sprig file.
    """
    # Write the sprig
    stream = storage.open_for_write()
    _write_table(rows, format, stream)
    stream.close()
    sprig = Sprig(
        name=name,
        storage=storage.config,
        config=TableConfig(start=0, stop=None, format=format),
    )
    dump_sprig(sprig_dir, sprig)
    return sprig


T = TypeVar("T")
P = ParamSpec("P")


def tracked_io(f: Callable[P, T]) -> Callable[P, T]:
    """
    A decorator for wrapping a function which performs IO using a sprig
    so that its corresponding config and metadata are tracked at runtime.

    Expects the first argument to be of type Sprig
    """

    def wrapper(*args: P.args, **kwargs: P.kwargs) -> T:
        # FIXME: do something less silly here
        sprig = cast(Sprig, args[0])
        dump_sprig(Path("sprigs"), sprig)
        return f(*args, **kwargs)

    return wrapper


@tracked_io
def read_table(sprig: Sprig, start: int = 0, stop: int | None = None) -> Table:
    if not isinstance(sprig.config, TableConfig):
        # TODO: There is surely a nicer way to check this at the type level
        raise RuntimeError("Read table was called for a sprig which is not a table.")

    match sprig.config.format:
        case CSV():
            if not isinstance(sprig.storage, LocalStorageConfig):
                raise Exception("Only local storage config is currently supported for CSV files.")
            stream = LocalStorage(config=sprig.storage).open()
            # FIXME: This loads the whole thing into memory
            table: pa.Table = csv.read_csv(stream)
            return Table(table.slice(start, stop))
        case SQL():
            if not isinstance(sprig.storage, DatabaseStorageConfig):
                raise Exception("Only database storage config is currently supported for SQL sources.")
            with SQLStorage(config=sprig.storage).open() as storage:
                storage: CursorResult[Any]
                # FIXME: This is a very inefficient way of doing this, but just for prototyping...
                table = storage.all()
            table = pa.Table.from_pylist([x._mapping for x in table])
            return Table(table.slice(start, stop))
        case _:
            raise RuntimeError(f"Unsupported format: {sprig.config.format}")


def _write_table(table: Table, format: Format, stream: BinaryIO) -> None:
    match format:
        case CSV():
            csv.write_csv(table._table, stream)
        case _:
            raise RuntimeError(f"Unsupported format: {format}")


def read(sprig: Sprig) -> Table:
    """Reads the sprig's data from its backing storage"""
    match sprig.config.format.structure:
        case Structure.TABLE:
            return read_table(sprig, start=sprig.config.start, stop=sprig.config.stop)
        case s:
            raise RuntimeError(f"A read method for the structure you provided, {s}, has not yet been implemented.")
