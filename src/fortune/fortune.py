import os
import random
import re
from pathlib import Path

DATFILES = (Path(__file__) / '..' / 'datfiles').resolve()

class Fortune:

    #def __init__(self):
    #    self.text=""
    #    self.id=0

    def __init__(self, text: str = "", id: int = 0):
        self.text = text
        self.id = id

    # Helper functions
    def _get_files(self):
        files = os.listdir(DATFILES)
        files.remove('LICENSE')
        return [DATFILES / file for file in files]

    def _load_fortunes(self):
        fortunes = []
        fortune_id = 0

        paths = self._get_files()

        for path in paths:
            with open(path, "r", encoding="utf-8", errors="ignore") as f:
                content = f.read()

            texts = content.split("%")

            for text in texts:
                text = text.strip()

                if not text:
                    continue

                text = text.replace("\\\n", "\n").replace("\\\t", "\t")

                fortune_id += 1
                fortune = Fortune(text, fortune_id)
                fortunes.append(fortune)

                #print(f"Loaded fortune {fortune_id}")

        return fortunes

    def _print_all_fortunes(self):
        fortunes = self._load_fortunes()
        print("Total:", len(fortunes))
        for fortune in fortunes[:100]:
            print(f"{fortune.id}: {fortune.text[:40]!r}")

    # Public functions
    def get_random_fortune(self):
        fortunes = self._load_fortunes()
        return random.choice(fortunes)

    def get_fortune_by_id(self, fortune_id: int):
        fortunes = self._load_fortunes()
        for fortune in fortunes:
            if fortune.id == fortune_id:
                return fortune
        return None

