import glob
import os
from pathlib import Path

import yaml
from pydantic.dataclasses import dataclass

from sprig.model import Sprig

SPRIG_EXT = "sprig"
"""File extension for sprig files"""


@dataclass
class LocalRepo:
    path: Path = Path("sprigs")

    def list_sprigs(self) -> list[str]:
        pattern = f"{self.path}/*.{SPRIG_EXT}"
        files = glob.glob(pattern)
        return [os.path.basename(os.path.splitext(f)[0]) for f in files]

    def get_sprig(self, name: str) -> Sprig:
        with open(self.path.joinpath(f"{name}.sprig")) as f:
            return Sprig.model_validate(yaml.safe_load(f))
