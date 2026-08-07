# Selects every most-common name by year and sex, retaining ties.

library("dplyr")

args <- commandArgs(trailingOnly = TRUE)

argument <- function(flag) {
  position <- match(flag, args)
  if (is.na(position) || position == length(args)) {
    stop("Usage: 2_summarize.R --input 1_names_clean.csv --output 2_yearly_winners.csv")
  }
  args[[position + 1]]
}

in_path <- argument("--input")
out_path <- argument("--output")

winners <- read.csv(in_path) |>
  group_by(sex, year) |>
  slice_max(order_by = births, n = 1) |>
  ungroup() |>
  arrange(desc(year), sex, name)

dir.create(dirname(out_path), recursive = TRUE, showWarnings = FALSE)
write.csv(winners, out_path, row.names = FALSE)
