# Fixing caption drift in the Module 2 dynamic-reporting demos

Date: 2026-08-07
Status: approved, ready for implementation planning

## Problem

Both Module 2 demos plot Zurich newborn-name data fetched live from a mutable
URL, but describe the plotted window in hardcoded prose.

The plot chunk filters `year > 2020`. The caption says `2021-2024`. The live
dataset now extends through 2025 (verified 2026-08-07: 2257 rows for year 2025,
71,842 lines total). So both demos currently render a 2021-2025 plot under a
caption reading "2021-2024". The caption is wrong the moment it renders, and
gets wronger every January.

The root cause is duplication, not staleness: the year window is stated twice,
once as executable code (`year > 2020`) and once as English (`2021-2024`).
Nothing keeps the two in sync. Fixing only the literal `2024` would leave the
duplication in place and the bug would return.

A second, unrelated finding: `demo_R/bev370od3700.csv` (1.9 MB, git-tracked, a
clean snapshot of the data minus the 2025 rows) is referenced by zero files.
Both demos read from the URL. It is dead weight.

A third: six render artifacts under `index_files/figure-pdf/` are git-tracked.

## Approach

State the year window **once**, in code, and derive every human-readable
mention of it from the data.

A new chunk before the plot binds the filtered frame and the derived range:

```r
# R
recent <- datclean |> filter(year > 2020)
yr_range <- paste0(min(recent$year), "-", max(recent$year))
```

```python
# Python
recent = datclean.loc[datclean["year"] > 2020]
yr_range = f"{recent['year'].min()}-{recent['year'].max()}"
```

The plot chunk then pipes from `recent` rather than re-filtering, so
`year > 2020` appears exactly once per file. Prose references `yr_range` via
inline code. The figure caption drops years entirely and becomes permanently
true.

This mirrors the guidance the R demo already gives at line 275: perform
computations in a separate chunk, save to a variable, print the variable
inline.

### Rejected alternative: `!expr` in the chunk option

`#| fig-cap: !expr paste0(...)` would give a genuinely dynamic caption under
knitr. It was rejected because it is R-only. Tested against Quarto 1.9.37: under
the jupyter engine it does not evaluate and instead **fails the render**:

```
ERROR: TypeError: caption.trim is not a function
    at mdFromCodeCell (quarto.js:33371:35)
```

Adopting it would fix the R demo and break the Python one, and would split two
tracks that are deliberately kept as mirrors of each other.

### Rejected alternative: figure div with inline-code caption

A `::: {#fig-names}` div whose final paragraph is the caption does support
inline code under both engines. Verified working: renders
`Figure 1: Most common names of Zurich newborns in 2021-2025.` with a
functioning `@fig-names` cross-reference.

Rejected on pedagogical grounds. The paragraph at `demo_R/index.qmd:217` exists
specifically to teach `#| fig-cap:` as a chunk option; replacing the chunk
option with a div deletes the thing that paragraph points at, and introduces div
syntax into a beginner section that has not earned it yet.

## Changes

### `contents/module_2_dynamic_reporting/demo_R/index.qmd`

| Line | Change |
| --- | --- |
| 196 | Prose "between 2021 and 2024" becomes a reference to `` `r yr_range` `` |
| ~197 | **New chunk** binding `recent` and `yr_range` |
| 200 | `fig-cap` becomes `"Most common names of Zurich newborns."` |
| 203-204 | Plot pipes from `recent`; the `filter(year > 2020)` line is removed |
| 217 | The quoted `#| fig-cap:` string in the teaching prose is updated to match |

### `contents/module_2_dynamic_reporting/demo_py/index.qmd`

| Line | Change |
| --- | --- |
| 193 | Prose "between 2021 and 2024" becomes a reference to `` `{python} yr_range` `` |
| ~194 | **New chunk** binding `recent` and `yr_range` |
| 197 | `fig-cap` becomes `"Most common names of Zurich newborns."` |
| 200-201 | `top10` builds from `recent`; the `.loc[... > 2020]` filter is removed |
| 222 | The quoted `#| fig-cap:` string in the teaching prose is updated to match |

The two files must stay structurally parallel. A student following the R track
and a student following the Python track should see the same lesson.

### Deletions

- `git rm contents/module_2_dynamic_reporting/demo_R/bev370od3700.csv`
- `git rm --cached` the six tracked render artifacts:
  - `demo_R/index_files/figure-pdf/fig-names-1.pdf`
  - `demo_R/index_files/figure-pdf/fig-names-over-time-1.pdf`
  - `demo_R/index_files/figure-pdf/fig-names-over-time-2.pdf`
  - `demo_py/index_files/figure-pdf/fig-names-output-1.png`
  - `demo_py/index_files/figure-pdf/fig-names-over-time-output-1.png`
  - `demo_py/index_files/figure-pdf/fig-names-over-time-output-2.png`

These artifacts are intermediates of the per-document `pdf: default` format.
The Pages workflow builds `contents/_site` from scratch on every push and
uploads only that, so the committed copies are never served. They are already
stale, having been rendered from an older data pull.

### `.gitignore`

Add, under the existing "Quarto build output" block:

```
**/*_files/
```

## Verification

Render both demos and confirm:

1. The caption reads "Most common names of Zurich newborns." with no years.
2. The prose above the plot names the range the data actually contains
   (`2021-2025` as of 2026-08-07).
3. `@fig-names` still resolves to "Figure 1".
4. `git status` is clean of `_files/` output afterwards.

**This cannot be verified on the machine where the design was written.** R is
not installed, and pandas/matplotlib/seaborn are not available to the local
Python. Verification requires either the workshop container
(`ghcr.io/a1eksb/operra-reproducibility:rstudio`) or CI. The Quarto caption
mechanics were verified locally against stub data; the demos themselves were
not executed. Implementation must not report success without a real render.

## Out of scope

**`freeze: auto` is currently inert.** `contents/_quarto.yml:100` sets
`freeze: auto`, but `.gitignore` excludes `_freeze/`, so CI begins every build
with an empty cache and re-executes every chunk against the live dataset. The
published site's figures and inline numbers can therefore change with no commit
behind the change.

That is the same defect as the caption bug one level up, and this spec does not
fix it. Resolving it means choosing between committing `_freeze/` (deterministic
builds, output changes only when someone re-executes) and accepting always-live
rebuilds (current de facto behaviour, and the `freeze: auto` line should then be
dropped as misleading). That choice belongs in its own spec.

The six stale artifacts are removed from tracking here but not regenerated; once
untracked, they no longer need to be.
