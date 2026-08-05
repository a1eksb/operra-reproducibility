#!/usr/bin/env python3
# Adds a z-score feature using the R summary and writes the processed CSV dataset.

import argparse
import math
from pathlib import Path

import polars as pl


def main() -> None:
    parser = argparse.ArgumentParser(description="Process derived dataset with polars (workshop demo)")
    parser.add_argument("--input", required=True, type=Path)
    parser.add_argument("--summary", required=True, type=Path)
    parser.add_argument("--output", required=True, type=Path)
    args = parser.parse_args()

    summary_kv: dict[str, str] = {}
    for line in args.summary.read_text().splitlines():
        if "=" not in line:
            continue
        key, value = line.split("=", 1)
        summary_kv[key.strip()] = value.strip()

    mean_s = float(summary_kv.get("value_centered_mean", "nan"))
    sd_s = float(summary_kv.get("value_centered_sd", "nan"))

    df = pl.read_csv(args.input)

    # Add a simple polars-derived feature for the report. It intentionally depends
    # on the R-produced summary so this step sits "between" R and Quarto.
    if math.isnan(mean_s):
        mean_s = float(df.select(pl.col("value_centered").mean()).item())
    if math.isnan(sd_s) or math.isclose(sd_s, 0.0, abs_tol=1e-12):
        sd_s = float(df.select(pl.col("value_centered").std(ddof=0)).item())
    if math.isnan(sd_s) or math.isclose(sd_s, 0.0, abs_tol=1e-12):
        sd_s = 1.0

    df = df.with_columns(
        ((pl.col("value_centered") - mean_s) / sd_s).alias("value_centered_z")
    )

    args.output.parent.mkdir(parents=True, exist_ok=True)
    df.write_csv(args.output)


if __name__ == "__main__":
    main()
