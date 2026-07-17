#!/usr/bin/env python3
# Centers the input values and writes the workflow's derived CSV dataset.

import argparse
import csv
from pathlib import Path


def main():
    p = argparse.ArgumentParser(description="Create derived dataset from example_data.csv (Python)")
    p.add_argument("--input", required=True, type=Path)
    p.add_argument("--output", required=True, type=Path)
    args = p.parse_args()

    rows = []
    values = []
    with args.input.open(newline="") as f:
        r = csv.DictReader(f)
        for row in r:
            year = int(row["year"])
            value = float(row["value"])
            rows.append((year, value))
            values.append(value)

    mean_v = sum(values) / len(values)

    args.output.parent.mkdir(parents=True, exist_ok=True)
    with args.output.open("w", newline="") as f:
        w = csv.writer(f)
        w.writerow(["year", "value", "value_centered"])
        for year, value in rows:
            w.writerow([year, value, value - mean_v])


if __name__ == "__main__":
    main()
