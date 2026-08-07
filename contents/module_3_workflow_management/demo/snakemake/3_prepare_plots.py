"""Prepare the two plot datasets used by the Module 2 report."""

import argparse
from pathlib import Path

import polars as pl


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--input", required=True, type=Path)
    parser.add_argument("--top-names-output", required=True, type=Path)
    parser.add_argument("--selected-names-output", required=True, type=Path)
    args = parser.parse_args()

    clean = pl.read_csv(args.input)

    top_names = (
        clean.filter(pl.col("year").is_between(2021, 2025))
        .group_by(["sex", "name"])
        .agg(pl.col("births").sum())
        .with_columns(
            pl.col("births")
            .rank(method="min", descending=True)
            .over("sex")
            .alias("birth_rank")
        )
        .filter(pl.col("birth_rank") <= 10)
        .drop("birth_rank")
        .sort(["sex", "births", "name"], descending=[False, True, False])
    )

    selected_names = (
        clean.filter(pl.col("name").is_in(["Peter", "Daniel"]))
        .group_by(["year", "name"])
        .agg(pl.col("births").sum())
        .sort(["name", "year"])
    )

    args.top_names_output.parent.mkdir(parents=True, exist_ok=True)
    args.selected_names_output.parent.mkdir(parents=True, exist_ok=True)
    top_names.write_csv(args.top_names_output)
    selected_names.write_csv(args.selected_names_output)


if __name__ == "__main__":
    main()
