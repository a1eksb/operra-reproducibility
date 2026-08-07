# Module 3 Demo — Nextflow

A minimal Nextflow pipeline demonstrating a reproducible multi-language workflow.
Each step depends on the previous one's output, so Nextflow enforces execution order automatically.

```
example_data.csv
      │
      ▼
 1_derive.py  (Python)  →  1_derived.csv
                                 │
                                 ▼
                         2_summary.R  (R)  →  2_summary.txt
                                                   │
                                                   ▼
               3_polars_process.py  (Python/polars)  →  3_processed.csv
                                                   │
                              ┌─────────────────────┘
                              ▼
                        4_report.qmd  (Quarto)  →  4_report.html
```

Step 3 intentionally introduces an additional dependency (`polars`) that may not be installed by default.

## Running the demo

### In GitHub Codespaces

The environment is already set up. Open a terminal and run:

```bash
cd /home/rstudio/project/contents/module_3_workflow_management/demo/nextflow
nextflow run main.nf
```

### On a host machine with Docker

From the repository root on your host machine:

```bash
# 1. Start the workshop container (first run only)
docker compose up -d

# 2. Open a shell inside the container
docker compose exec pyverse bash

# 3. Enter the demo directory and run the workflow
cd /home/rstudio/project/contents/module_3_workflow_management/demo/nextflow
nextflow run main.nf
```

Results are published to `results/`:
- `results/1_derived.csv`
- `results/2_summary.txt`
- `results/3_processed.csv`
- `results/4_report.html`

Override the output directory with `--outdir`:

```bash
nextflow run main.nf --outdir my_results
```

## Resuming from a cached run

Nextflow caches the result of every step in the `work/` directory.
If you change one script and re-run with `-resume`, only that step and the
steps downstream of it are re-executed — everything upstream is skipped.

```bash
nextflow run main.nf -resume
```

For example, if you edit `2_summary.R`:

```
 1_derive.py  ✔ cached   (no re-run)
 2_summary.R  ↻ re-runs  (you changed this)
 3_polars_process.py ↻ re-runs  (depends on 1_derived.csv)
 4_report.qmd ↻ re-runs  (depends on downstream outputs)
```

This is one of the core reproducibility benefits of a workflow manager:
you never re-run more than necessary, and you never accidentally skip a
step that depends on something you just changed.

## Switching between PDF and HTML output

The report format is controlled by the `format:` key at the top of `4_report.qmd`
and the `--to` flag passed to Quarto in `main.nf`.

**To render as HTML** (emojis and interactive features work out of the box):

In `4_report.qmd`, change:
```yaml
format:
  pdf:
    toc: true
```
to:
```yaml
format:
  html:
    toc: true
```

And in `main.nf`, update the `FINAL_REPORT` script and output:
```groovy
output:
path "4_report.html"

script:
"""
quarto render 4_report.qmd --to html --output 4_report.html --output-dir .
"""
```

**To render as PDF** (default, requires a LaTeX installation):

Keep `format: pdf` in `4_report.qmd` and `--to pdf` in `main.nf`.

> Note: emojis in section headings are silently dropped by the default PDF engine (pdflatex).
> Switch to `pdf-engine: lualatex` in `4_report.qmd` if you need emoji support in PDFs —
> this requires installing the `emoji` LaTeX package and an emoji font in the Docker image.

## Cleaning up

```bash
# Remove Nextflow work directory and results
rm -rf work results .nextflow .nextflow.log*
```

On a host machine, also stop the container:

```bash
docker compose down
```
