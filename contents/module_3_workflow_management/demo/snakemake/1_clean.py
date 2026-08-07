"""Download and clean the Zurich newborn-names dataset."""

import argparse
from pathlib import Path

import pandas as pd

COLUMN_NAMES = {
    "StichtagDatJahr": "year",
    "Vorname": "name",
    "SexLang": "sex",
    "AnzGebuWir": "births",
}
SEX_NAMES = {"weiblich": "female", "männlich": "male"}


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--url", required=True)
    parser.add_argument("--output", required=True, type=Path)
    args = parser.parse_args()

    raw = pd.read_csv(args.url)
    missing = COLUMN_NAMES.keys() - raw.columns
    if missing:
        raise ValueError(f"Input data is missing columns: {sorted(missing)}")

    clean = raw.rename(columns=COLUMN_NAMES)[list(COLUMN_NAMES.values())].copy()
    clean["sex"] = clean["sex"].replace(SEX_NAMES)
    clean["year"] = pd.to_numeric(clean["year"], errors="raise").astype(int)
    clean["births"] = pd.to_numeric(clean["births"], errors="raise").astype(int)
    clean.sort_values(["year", "sex", "name"], inplace=True)

    args.output.parent.mkdir(parents=True, exist_ok=True)
    clean.to_csv(args.output, index=False)


if __name__ == "__main__":
    main()
