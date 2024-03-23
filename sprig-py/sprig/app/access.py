import glob
import yaml

import os

from sprig.model import Sprig


class Access:
    """Methods for managing / reading sprigs"""

    def list_sprigs(self) -> list[str]:
        files = glob.glob("./sprigs/*.sprig")
        return [os.path.basename(os.path.splitext(f)[0]) for f in files]

    def get_sprig(self, name: str) -> Sprig:
        with open(f"sprigs/{name}.sprig") as f:
            return Sprig.model_validate(yaml.safe_load(f))
