import json
import subprocess
from io import BytesIO
from typing import Protocol

from pyarrow import ipc

from sprig.model import LocalStorageConfig, Rows, Sprig, StorageConfig


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

    def read_sprig(self, name: str) -> Rows:
        # FIXME: We currently return a Rows from this, but likely we want to
        # return a Rows or a Columns or a Blob. The interchange format I'm using
        # is just an Arrow table, which will not work the the Blob case. We'll
        # want to explore options for this further.
        """Reads a sprig"""
        ...

    def create_from_rows(
        self, name: str, rows: Rows, storage_config: StorageConfig
    ) -> Sprig:
        ...


class LocalBasket(Basket):
    """
    A Basket hosted in the local filesystem

    This basket uses the sprig CLI as its back-end.
    """

    def __init__(self, basket_path: str, sprig_backend_path: str = "sprig"):
        """
        Args:
            basket_path: The path to the basket. A basket is a directory containing .sprig files.
            sprig_backend_path: The path to the sprig CLI which will be used for interacting with the basket.
        """
        self.basket_path = basket_path
        self.sprig_backend_path = sprig_backend_path

    def list_sprigs(self) -> list[Sprig]:
        stream = subprocess.Popen(f"{self.sprig_backend_path} --basket {self.basket_path} list", shell=True, stdout=subprocess.PIPE)
        stream.wait(timeout=10)
        result = stream.stdout.read()  # type: ignore
        names = json.loads(result)["sprigs"]  # type: ignore
        return names

    def get_sprig(self, name: str) -> Sprig:
        stream = subprocess.Popen(
            f"{self.sprig_backend_path} --basket {self.basket_path} get --name {name}", shell=True, stdout=subprocess.PIPE
        )
        stream.wait(timeout=10)
        sprig = Sprig.model_validate_json(stream.stdout.read())  # type: ignore
        return sprig

    def read_sprig(self, name: str) -> Rows:
        # Call the CLI and get the arrow ipc stream it outputs
        stream = subprocess.Popen(
            f"{self.sprig_backend_path} --basket {self.basket_path} read --name {name}", shell=True, stdout=subprocess.PIPE
        )
        stream.wait(timeout=60)
        reader = ipc.open_stream(stream.stdout)
        data = reader.read_all()
        return Rows(data)

    def create_from_rows(
        self, name: str, rows: Rows, storage_config: StorageConfig
    ) -> Sprig:
        # Prepare payload to pass to back-end
        buffer = BytesIO()
        writer = ipc.new_stream(buffer, rows._table.schema)
        writer.write(rows._table)
        buffer.seek(0)

        match storage_config:
            case LocalStorageConfig() as local:
                cmd = (f"sprig create --name {name} --path {local.path}",)
            case _:
                raise RuntimeError("Unsupported storage config!")

        result = subprocess.run(
            cmd,
            shell=True,
            stdout=subprocess.PIPE,
            input=buffer.read(),
        )
        return Sprig.model_validate_json(result.stdout)
