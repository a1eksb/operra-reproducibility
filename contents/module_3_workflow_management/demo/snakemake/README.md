# Module 3 Demo — Snakemake

A minimal Snakemake pipeline demonstrating a reproducible multi-language workflow.
Snakemake figures out the execution order automatically by matching rule inputs to outputs.

```
example_data.csv
      │
      ▼
 1_derive.py  (Python)  →  work/1_derived.csv
                                  │
                                  ▼
                       2_summary.R  (R)  →  work/2_summary.txt
                                                   │
                                                   ▼
            3_polars_process.py  (Python/polars)  →  work/3_processed.csv
                                                   │
                            ┌───────────────────────┘
                            ▼
              4_report.qmd  (Quarto — you write this)  →  results/4_report.html
```

Step 3 intentionally introduces an additional dependency (`polars`) that may not be installed by default.

## The final step is yours

`4_report.qmd` ships as a skeleton with "Your task" instructions. Using what
you learned in the dynamic reporting module, fill it with code chunks that read
the pipeline outputs (`work/1_derived.csv`, `work/2_summary.txt`,
`work/3_processed.csv`) and turn them into tables, a figure, and inline
statistics. The skeleton renders as-is, so the pipeline works before you start.
Hints and full solutions are on the Module 3 hands-on page.

## Running the demo

### In GitHub Codespaces

The environment is already set up. Open a terminal and run:

```bash
cd /home/rstudio/project/contents/module_3_workflow_management/demo/snakemake
snakemake --cores 1
```

### On a host machine with Docker

From the repository root on your host machine:

```bash
# 1. Start the workshop container (first run only)
docker compose up -d

# 2. Open a shell inside the container
docker compose exec pyverse bash

# 3. Enter the demo directory and run the workflow
cd /home/rstudio/project/contents/module_3_workflow_management/demo/snakemake
snakemake --cores 1
```

Results are published to `results/`:
- `results/4_report.html`

If you run `snakemake` from outside `demo/snakemake/`, pass an explicit working directory and Snakefile:

```bash
snakemake \
  --directory /home/rstudio/project/contents/module_3_workflow_management/demo/snakemake \
  --snakefile /home/rstudio/project/contents/module_3_workflow_management/demo/snakemake/Snakefile \
  --cores 1
```

## Re-running after changes

Snakemake tracks whether output files are newer than their inputs.
If you change a script and re-run, it automatically re-runs only the affected
rules and everything downstream — no special flag needed.

```bash
snakemake --cores 1
```

For example, if you edit `2_summary.R`:

```
 py_derive    — skipped  (outputs are up to date)
 r_summary    — re-runs  (you changed this script)
 polars_process — re-runs  (depends on the changed 2_summary.txt)
 final_report   — re-runs  (depends on downstream outputs)
```

To force a specific rule to re-run regardless of timestamps:

```bash
snakemake --cores 1 --forcerun r_summary
```

To force a complete re-run from scratch:

```bash
snakemake --cores 1 --forceall
```

## Cleaning up

```bash
# Remove outputs and Snakemake metadata
rm -rf work results .snakemake
```

On a host machine, also stop the container:

```bash
docker compose down
```
