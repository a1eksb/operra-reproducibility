#!/usr/bin/env Rscript
# Summarizes the derived CSV with R for downstream workflow steps.

args <- commandArgs(trailingOnly = TRUE)

usage <- function() {
  cat("Usage: 2_summary.R --input 1_derived.csv --output 2_summary.txt\n")
  quit(status = 2)
}

in_path <- args[match("--input", args) + 1]
out_path <- args[match("--output", args) + 1]
if (is.na(in_path) || is.na(out_path)) usage()

df <- read.csv(in_path)
df$year          <- as.integer(df$year)
df$value_centered <- as.numeric(df$value_centered)

lines <- c(
  "module=2",
  "language=R",
  paste0("n=", nrow(df)),
  paste0("year_min=", min(df$year)),
  paste0("year_max=", max(df$year)),
  paste0("value_centered_mean=", sprintf("%.3f", mean(df$value_centered))),
  paste0("value_centered_sd=",   sprintf("%.3f", sd(df$value_centered)))
)
writeLines(lines, con = out_path)
