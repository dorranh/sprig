from pathlib import Path
from typing import Any, BinaryIO
from uuid import uuid4

import yaml
from pyarrow import Table, csv
from sqlalchemy import CursorResult

from sprig.app.storage import LocalStorage, SQLStorage
from sprig.model import (
    DatabaseStorageConfig,
    Format,
    LocalStorageConfig,
    RowConfig,
    Rows,
    Sprig,
    Structure,
)


def sprig_from_rows(name: str, rows: "Rows", storage: LocalStorage, format: Format = Format.CSV) -> "Sprig":
    # Write the sprig
    # TODO [Dorran] Pick back up here
    stream = storage.open_for_write()
    write_rows(rows, format, stream)
    stream.close()
    sprig = Sprig(
        id=uuid4(),
        name=name,
        storage=storage.info,
        format=format,
        read_config=RowConfig(start=0, stop=None),
        structure=Structure.ROWS,
    )
    # FIXME: Do something cleaner here when it comes to writing out metadata
    with open(f"./sprigs/{sprig.name}.sprig", "w") as f:
        print(yaml.dump(sprig.model_dump(mode="json")), file=f)
    return sprig


def tracked(func):
    def wrapper(*args, **kwargs):
        # FIXME: do something less silly here
        sprig: Sprig = args[0]
        # FIXME: This needs to be configurable
        sprig_dir = Path("sprigs")
        sprig_dir.mkdir(exist_ok=True)
        sprig_path = sprig_dir.joinpath(f"{sprig.name}.sprig")
        with sprig_path.open("w") as f:
            print(yaml.dump(sprig.model_dump(mode="json")), file=f)
        return func(*args, **kwargs)

    return wrapper


# Note: This is the integration layer for sprig data to the types you want to use
# in your analysis, 3rd party libs, etc.


@tracked
def read_rows(sprig: Sprig, start: int = 0, stop: int | None = None) -> Rows:
    match sprig.format:
        case Format.CSV:
            if not isinstance(sprig.storage, LocalStorageConfig):
                raise Exception("Only local storage config is currently supported for CSV files.")
            stream = LocalStorage(info=sprig.storage).open()
            # FIXME: This loads the whole thing into memory
            table: Table = csv.read_csv(stream)
            return Rows(table.slice(start, stop))
        case Format.SQL:
            if not isinstance(sprig.storage, DatabaseStorageConfig):
                raise Exception("Only database storage config is currently supported for SQL sources.")
            with SQLStorage(config=sprig.storage).open() as storage:
                storage: CursorResult[Any]
                # FIXME: This is a very inefficient way of doing this, but just for prototyping...
                rows = storage.all()
            table = Table.from_pylist([x._mapping for x in rows])
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
            return read_rows(sprig, start=sprig.read_config.start, stop=sprig.read_config.stop)
        case _:
            raise RuntimeError("Explode!")
