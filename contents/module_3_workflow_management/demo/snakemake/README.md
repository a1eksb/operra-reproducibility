# Module 3 Demo — Snakemake

This workflow repeats the Zurich newborn-names analysis from Module 2 and
renders the report the student created there.

## Pipeline

```text
Zurich Open Data URL
         |
   1_clean.py (pandas)
         |
work/1_names_clean.csv
   |
   +-- 2_summarize.R (dplyr) ------> work/2_yearly_winners.csv --+
   |                                                              |
   +-- 3_prepare_plots.py (Polars)                                 |
          +-- output 1: work/3_top_names.csv ----------------------+--> 4_report.qmd
          +-- output 2: work/3_selected_names.csv -----------------+          |
                                                                       results/4_report.html
```

`3_prepare_plots.py` is one rule with two declared output files. The summary
and plot-preparation rules both depend on the cleaned data, so Snakemake can run
them independently before rendering the report.

## Prepare your report

Copy the report you created in Module 2 over the supplied template:

```bash
cp "/path/to/your-module-2-report.qmd" 4_report.qmd
```

If it uses a local bibliography, also copy `references.bib` into this
directory. Adapt the report to read the four CSV paths shown above instead of
downloading and transforming the source data itself.

## Run in GitHub Codespaces

```bash
cd /home/rstudio/project/contents/module_3_workflow_management/demo/snakemake
snakemake --cores 1
```

Open `results/4_report.html` when the workflow finishes.

## Run with Docker

From the repository root on the host:

```bash
docker compose up -d
docker compose exec pyverse bash
cd /home/rstudio/project/contents/module_3_workflow_management/demo/snakemake
snakemake --cores 1
```

## Observe selective reruns

Run the same command after making a change:

- Editing `4_report.qmd` reruns only `final_report`.
- Editing `2_summarize.R` reruns `summarize_yearly` and `final_report`.
- Editing `3_prepare_plots.py` reruns `prepare_plots` and `final_report`.
- Editing `1_clean.py` reruns the complete downstream analysis.

To force one rule or the complete workflow:

```bash
snakemake --cores 1 --forcerun summarize_yearly
snakemake --cores 1 --forceall
```

## Inspect the workflow

```bash
snakemake --rulegraph | dot -Tsvg > rulegraph.svg
snakemake --dag | dot -Tsvg > dag.svg
snakemake --cores 1
snakemake --report execution-report.html
```

The rule graph shows the workflow definition. The DAG shows the concrete jobs
and files required for the current run.
