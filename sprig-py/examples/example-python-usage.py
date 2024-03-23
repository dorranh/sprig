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

from sprig.model import *
from sprig.client.basket import LocalBasket


# # In this example we CREATE a sprig
#     sprig = Sprig(
#         id=uuid4(),
#         name="demo-sprig",
#         structure=Structure.ROWS,
#         format=Format.CSV,
#         read_config=RowConfig(start=2, stop=None),
#         storage=LocalStorageConfig(path="./example-data/my-dataset.csv"),
#     )
#     print(f"Here is your sprig: {sprig}")
#     print(read(sprig).to_pandas())
#

# FIXME [Dorran]: Currently left off here during refactor. Need to clean up
# Basket API and use it in the examples below.


def main():
    basket = LocalBasket()

    print("Sprigs in the basket:")
    print(basket.list_sprigs())

    print("Running first analysis script")

    my_analysis()

    print("Running a second analysis script which depends on the output of the first")
    another_analysis()

    print("Calling executable and reading its output:")
    print(LocalBasket().read_sprig_rows("demo-sprig"))
    print("DONE!")


def my_analysis(basket: LocalBasket):
    "Reads a pre-existing sprig"
    sprig = basket.get_sprig("demo-sprig")
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
