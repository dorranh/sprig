import click
import pandas as pd
from dataclasses import dataclass
from enum import Enum
from uuid import uuid4
from pydantic import BaseModel
from pydantic.types import UUID4
from pyarrow import Table, csv, ipc
import subprocess
import yaml

from typing import NewType, BinaryIO, Tuple
import glob
import os

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
