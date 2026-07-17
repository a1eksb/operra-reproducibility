# Snakemake Demo: "Write Your Own Dynamic Report" Exercise — Design

**Date:** 2026-07-17
**Status:** Approved

## Goal

Turn the final step of the Module 3 Snakemake demo into a hands-on exercise:
learners apply what they learned in Module 2 (dynamic reporting with Quarto) by
authoring the report themselves. The report consumes the pipeline's script
outputs and renders a *dynamic* HTML report (executed code chunks), replacing
the current finished *static* report (`eval: false` + `{{< include >}}`).

Only the Snakemake demo changes. The Nextflow demo keeps its finished static
report and serves as a contrast.

## Decisions (made with the user)

1. **Starting point:** skeleton with TODOs — not a blank slate, not a separate
   exercise file. `4_report.qmd` is replaced in place.
2. **Language:** learner's choice. TODOs are language-neutral; hints and
   solutions are provided in both R and Python.
3. **Solutions:** collapsible Hint/Solution callouts on the Module 3 hands-on
   page (`demo/index.qmd`), not a solution file inside the pipeline directory.

## Changes

### 1. `contents/module_3_workflow_management/demo/snakemake/4_report.qmd` → skeleton

- Working YAML header kept: `title`, `format: html` with `toc` and
  `embed-resources: true`.
- **Remove `execute: eval: false`** — learners' code chunks must execute.
- Intro paragraph framing the exercise: apply Module 2 knowledge; the file is
  rendered by the pipeline's `final_report` rule.
- Four sections, each containing a "Your task" callout (`.callout-note` or
  similar) instead of finished content:
  1. **Setup** — TODO: load your libraries (R: dplyr/ggplot2/kableExtra, or
     Python: pandas/itables/matplotlib/seaborn — whichever Module 2 flavor you
     followed).
  2. **Derived data** — TODO: read `work/1_derived.csv` with code and display
     it as a table.
  3. **Summary statistics** — TODO: read `work/2_summary.txt` and print its
     contents. The callout mentions `{{< include >}}` as the static
     alternative and why reading it with code is the dynamic route.
  4. **Processed data** — TODO: read `work/3_processed.csv` and plot the
     centred values against the polars-derived feature, with `#| fig-cap` and
     `#| label` chunk options as taught in Module 2.
- **Bonus** section — TODO: report a computed value (e.g., number of rows) as
  inline code in a sentence.
- Constraint: the skeleton **must render successfully as shipped** (callouts
  are plain markdown, no code chunks yet), so `snakemake --cores 1` works out
  of the box and the workflow demo never blocks on the exercise.
- The iteration loop is itself Module 3 reinforcement: edit `4_report.qmd`,
  re-run `snakemake --cores 1`, observe that only `final_report` re-runs.

### 2. `Snakefile` — no functional changes

The `final_report` rule already lists all three artifacts as inputs and renders
`4_report.qmd`. Only the header comment (line 5) is reworded from "Quarto
collects outputs into an HTML report" to reflect that learners write the
report.

### 3. `contents/module_3_workflow_management/demo/index.qmd` — new subsection

Under the Snakemake section, add **"Your turn: write the dynamic report"**:

- States the task and links back to the Module 2 hands-on pages (R and Python).
- Explains the edit → `snakemake --cores 1` → open `results/4_report.html`
  loop, and that Snakemake re-runs only `final_report`.
- Collapsible callouts (`collapse="true"`):
  - one **Hint** callout — which functions to reach for in each language
    (e.g., `read.csv`/`kable`/`ggplot` vs. `pd.read_csv`/`itables`/
    `matplotlib`), no full code;
  - one **Solution (R)** callout — complete working report source;
  - one **Solution (Python)** callout — complete working report source.
- Solutions must only use libraries present in the workshop image
  (verified: pandas, itables, matplotlib, seaborn, polars on the Python side;
  dplyr, ggplot2, kableExtra on the R side).
- Mentions the contrast: the Nextflow variant ships a finished *static*
  include-based report; here you author a *dynamic* one.

### 4. `contents/module_3_workflow_management/demo/snakemake/README.md`

- ASCII diagram annotation: `4_report.qmd  (Quarto)` → note that learners
  write this file ("you write this").
- Short "The final step is yours" paragraph pointing at the skeleton and the
  hands-on page.

### 5. Out of scope

- Nextflow demo (`demo/nextflow/`): untouched.
- Module 2 content: untouched.
- Docker image / dependencies: untouched (solutions restricted to what is
  already installed).

## Error handling

- If a learner's chunk errors, `quarto render` fails, `final_report` fails, and
  Snakemake reports the failing rule — this is expected workshop behavior and
  is called out in the hands-on subsection (read the error, fix, re-run).
- Paths in the report are relative to the Snakefile directory because the
  `final_report` rule `cd`s there before rendering; solutions use relative
  paths (`work/1_derived.csv` etc.).

## Testing

- Render the shipped skeleton standalone (`quarto render 4_report.qmd`) — must
  succeed with no code execution.
- Run the full pipeline (`snakemake --cores 1`) from a clean state — must
  produce `results/4_report.html`.
- Paste each solution (R and Python) into the skeleton and re-run the pipeline
  — both must render with executed tables/plots.
- Render the course site page (`demo/index.qmd`) — callouts collapse correctly.
