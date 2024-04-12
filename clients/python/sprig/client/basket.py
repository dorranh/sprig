import json
import subprocess
from io import BytesIO
from typing import Protocol

from pyarrow import ipc

from sprig.model import LocalStorageConfig, Sprig, Table


class Basket(Protocol):
    """
    A Basket is a reference to one or more sprigs and implements
    methods for acccesing them.
    """

    def list_sprigs(self) -> list[Sprig]:
        """Lists the sprigs available in this basket"""
        ...

    def get_sprig(self, name: str) -> Sprig:
        """Get a sprig by name"""
        ...

    def read_sprig(self, name: str) -> Table:
        # FIXME: We currently return a Rows from this, but likely we want to
        # return a Rows or a Columns or a Blob. The interchange format I'm using
        # is just an Arrow table, which will not work the the Blob case. We'll
        # want to explore options for this further.
        """Reads a sprig"""
        ...

    def create_from_rows(self, name: str, rows: Table, storage_config: LocalStorageConfig) -> Sprig:
        ...


class LocalBasket(Basket):
    """
    A Basket hosted in the local filesystem

    Currently this assumes that sprigs are stored in ./sprigs
    """

    def list_sprigs(self) -> list[Sprig]:
        stream = subprocess.Popen("sprig list", shell=True, stdout=subprocess.PIPE)
        stream.wait(timeout=10)
        result = stream.stdout.read()  # type: ignore
        names = json.loads(result)["sprigs"]  # type: ignore
        return names

    def get_sprig(self, name: str) -> Sprig:
        stream = subprocess.Popen(f"sprig get --name {name}", shell=True, stdout=subprocess.PIPE)
        stream.wait(timeout=10)
        sprig = Sprig.model_validate_json(stream.stdout.read())  # type: ignore
        return sprig

    def read_sprig(self, name: str) -> Table:
        # Call the CLI and get the arrow ipc stream it outputs
        stream = subprocess.Popen(f"sprig read --name {name}", shell=True, stdout=subprocess.PIPE)
        stream.wait(timeout=60)
        reader = ipc.open_stream(stream.stdout)
        data = reader.read_all()
        return Table(data)

    def create_from_rows(self, name: str, rows: Table, storage_config: LocalStorageConfig) -> Sprig:
        # Prepare payload to pass to back-end
        buffer = BytesIO()
        writer = ipc.new_stream(buffer, rows._table.schema)
        writer.write(rows._table)
        buffer.seek(0)

        # TODO: support other structures
        cmd = (f"sprig create --name {name} --path {storage_config.path} --structure table",)

        result = subprocess.run(
            cmd,
            shell=True,
            stdout=subprocess.PIPE,
            input=buffer.read(),
        )
        return Sprig.model_validate_json(result.stdout)
