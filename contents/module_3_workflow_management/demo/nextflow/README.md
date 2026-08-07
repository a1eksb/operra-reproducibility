# Module 3 Demo — Nextflow

This workflow repeats the Zurich newborn-names analysis from Module 2 and
renders the report the student created there.

## Pipeline

```text
Zurich Open Data URL
         |
   CLEAN_NAMES (pandas)
         |
1_names_clean.csv
   |
   +-- SUMMARIZE_YEARLY (dplyr) --> 2_yearly_winners.csv --+
   |                                                        |
   +-- PREPARE_PLOTS (Polars)                               |
          +-- output 1: 3_top_names.csv --------------------+--> FINAL_REPORT
          +-- output 2: 3_selected_names.csv ---------------+         |
                                                               4_report.html
```

`PREPARE_PLOTS` is one process with two declared output files. The summary and
plot-preparation processes both consume the cleaned-data channel, so they can
run independently before `FINAL_REPORT`.

## Prepare your report

Copy the report you created in Module 2 over the supplied template:

```bash
cp "/path/to/your-module-2-report.qmd" 4_report.qmd
```

If it uses a local bibliography, also copy it as `references.bib`. Nextflow
stages that file with the report when it is present.

Adapt the report to read these staged filenames:

- `1_names_clean.csv`
- `2_yearly_winners.csv`
- `3_top_names.csv`
- `3_selected_names.csv`

Do not add a `results/` prefix inside the report.

## Run in GitHub Codespaces

```bash
cd /home/rstudio/project/contents/module_3_workflow_management/demo/nextflow
nextflow run main.nf
```

Open `results/4_report.html` when the workflow finishes. The prepared CSV files
are also published to `results/` for inspection.

## Run with Docker

From the repository root on the host:

```bash
docker compose up -d
docker compose exec pyverse bash
cd /home/rstudio/project/contents/module_3_workflow_management/demo/nextflow
nextflow run main.nf
```

## Observe selective reruns

Use `-resume` after the first run:

```bash
nextflow run main.nf -resume
```

- Editing `4_report.qmd` reruns only `FINAL_REPORT`.
- Editing `2_summarize.R` reruns `SUMMARIZE_YEARLY` and `FINAL_REPORT`.
- Editing `3_prepare_plots.py` reruns `PREPARE_PLOTS` and `FINAL_REPORT`.
- Editing `1_clean.py` reruns the complete downstream analysis.

Publish results elsewhere with `--outdir`, if needed:

```bash
nextflow run main.nf -resume --outdir alternative-results
```

## Inspect the workflow

```bash
nextflow run main.nf -resume \
  -with-dag flowchart.svg \
  -with-report execution-report.html \
  -with-timeline timeline.html
```
