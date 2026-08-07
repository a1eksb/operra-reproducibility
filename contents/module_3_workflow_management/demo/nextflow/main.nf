#!/usr/bin/env nextflow

/*
 * Zurich newborn-names analysis from Module 2:
 * 1. Python downloads and cleans the source data    → 1_names_clean.csv
 * 2. R selects yearly winners, retaining ties       → 2_yearly_winners.csv
 * 3. Polars prepares both plot datasets             → 3_*.csv
 * 4. Quarto renders the adapted Module 2 report     → 4_report.html
 *
 * The summary and plotting processes branch from the same cleaned data.
 */

params.outdir = (params.outdir ?: 'results')
params.data_url = (params.data_url ?: 'https://data.stadt-zuerich.ch/dataset/bev_vornamen_baby_od3700/download/BEV370OD3700.csv')

workflow {
  def clean = CLEAN_NAMES( params.data_url, file('1_clean.py') )
  def winners = SUMMARIZE_YEARLY( clean, file('2_summarize.R') )
  def plot_data = PREPARE_PLOTS( clean, file('3_prepare_plots.py') )

  FINAL_REPORT(
    file('4_report.qmd'),
    clean,
    winners,
    plot_data
  )
}

process CLEAN_NAMES {
  publishDir "${params.outdir}", mode: 'copy'

  input:
  val data_url
  path "1_clean.py"

  output:
  path "1_names_clean.csv"

  script:
  """
  python3 1_clean.py --url "${data_url}" --output 1_names_clean.csv
  """
}

process SUMMARIZE_YEARLY {
  publishDir "${params.outdir}", mode: 'copy'

  input:
  path "1_names_clean.csv"
  path "2_summarize.R"

  output:
  path "2_yearly_winners.csv"

  script:
  """
  Rscript 2_summarize.R --input 1_names_clean.csv --output 2_yearly_winners.csv
  """
}

process PREPARE_PLOTS {
  publishDir "${params.outdir}", mode: 'copy'

  input:
  path "1_names_clean.csv"
  path "3_prepare_plots.py"

  output:
  tuple path("3_top_names.csv"), path("3_selected_names.csv")

  script:
  """
  python3 3_prepare_plots.py \
    --input 1_names_clean.csv \
    --top-names-output 3_top_names.csv \
    --selected-names-output 3_selected_names.csv
  """
}

process FINAL_REPORT {
  publishDir "${params.outdir}", mode: 'copy'

  input:
  path "4_report.qmd"
  path "1_names_clean.csv"
  path "2_yearly_winners.csv"
  tuple path("3_top_names.csv"), path("3_selected_names.csv")

  output:
  path "4_report.html"

  script:
  // Render outside the repo so Quarto does not inherit the website project.
  """
  workdir=\$(pwd)
  tmpdir=\$(mktemp -d)
  cp 4_report.qmd 1_names_clean.csv 2_yearly_winners.csv \
    3_top_names.csv 3_selected_names.csv "\$tmpdir/"
  cd "\$tmpdir"
  quarto render 4_report.qmd --to html --output 4_report.html
  cp 4_report.html "\$workdir/"
  """
}
