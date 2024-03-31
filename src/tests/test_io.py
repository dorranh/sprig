import os
import sqlite3
import tempfile
from uuid import uuid4

import pytest

from sprig.app.io import read_rows
from sprig.model import DatabaseStorageConfig, Format, RowConfig, Sprig, Structure

TEST_TABLE = "test_data"


@pytest.fixture
def sqlite_db():
    directory = tempfile.TemporaryDirectory(dir=os.getcwd())
    db_file = os.path.join(directory.name, "test.sqlite")
    connection = sqlite3.connect(db_file)
    connection.execute(
        """
        CREATE TABLE IF NOT EXISTS test_data (
        columnA int,
        columnB VARCHAR(100)
        );
    """
    )
    connection.execute(
        """
        INSERT INTO test_data (columnA, columnB) VALUES
            (1, "foo"),
            (2, "bar");
        """
    )
    connection.commit()
    connection.close()
    yield db_file
    directory.cleanup()


def test_read_sql_rows(sqlite_db: str):
    print(sqlite_db)
    sprig = Sprig(
        id=uuid4(),
        name="test",
        storage=DatabaseStorageConfig(connection_string=f"sqlite:///{sqlite_db}", query=f"SELECT * FROM {TEST_TABLE}"),
        structure=Structure.ROWS,
        format=Format.SQL,
        read_config=RowConfig(start=0, stop=None),
    )
    rows = read_rows(sprig)
    assert len(rows.to_pandas()) == 2
    assert rows.to_pandas().columns.values.tolist() == ["columnA", "columnB"]
