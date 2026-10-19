"""Prepare the two plot datasets used by the Module 2 report."""

import argparse
from pathlib import Path

import pandas as pd


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--input", required=True, type=Path)
    parser.add_argument("--top-names-output", required=True, type=Path)
    parser.add_argument("--selected-names-output", required=True, type=Path)
    args = parser.parse_args()

    clean = pd.read_csv(args.input)

    top_names = (
        clean[clean["year"].between(2021, 2025)]
        .groupby(["sex", "name"], as_index=False)["births"]
        .sum()
    )
    # "min" ranking keeps every name tied at the cutoff.
    birth_rank = top_names.groupby("sex")["births"].rank(method="min", ascending=False)
    top_names = top_names[birth_rank <= 10].sort_values(
        ["sex", "births", "name"], ascending=[True, False, True]
    )

    selected_names = (
        clean[clean["name"].isin(["Peter", "Daniel"])]
        .groupby(["year", "name"], as_index=False)["births"]
        .sum()
        .sort_values(["name", "year"])
    )

    args.top_names_output.parent.mkdir(parents=True, exist_ok=True)
    args.selected_names_output.parent.mkdir(parents=True, exist_ok=True)
    top_names.to_csv(args.top_names_output, index=False)
    selected_names.to_csv(args.selected_names_output, index=False)


if __name__ == "__main__":
    main()
