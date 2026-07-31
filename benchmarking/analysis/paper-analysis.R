### In this file, we aggregate the raw data
### for use in presentation in the paper.

library(readxl)
library(dplyr)
library(purrr)

# ── Configuration ─────────────────────────────────────────────────────────────

BASE_PATH   <- "~/git/flaspland-encodings/benchmarking/"
FILE_PREFIX <- "results-dist-"
SUFFIXES    <- c("mce", "mch", "mcs")

TRAINS_COL_IDX  <- 1
TRAINS_CHAR_POS <- 9
STATUS_COL      <- "rstatus"

# ── Helpers ───────────────────────────────────────────────────────────────────

extract_trains <- function(df) {
  as.integer(substr(pull(df, TRAINS_COL_IDX), TRAINS_CHAR_POS, TRAINS_CHAR_POS))
}

instances_for <- function(trains) {
  if_else(trains == 7L, 10L, 70L)
}

# ── Per-experiment processing ─────────────────────────────────────────────────

process_experiment <- function(suffix) {
  path <- file.path(BASE_PATH, paste0(FILE_PREFIX, suffix, ".xlsx"))
  
  raw <- read_excel(path, skip = 1) |>
    select(1:18) |>
    rename(
      "overall-time"  = "overall-time...9",
      "solving-time"  = "solving-time...14",
      rules           = "rules...13",
      variables       = "variables...18",
      constraints     = "constraints...4"
    ) |>
    mutate(trains = extract_trains(pick(everything())))
  
  # Timeout count per trains value (before filtering)
  timeout_counts <- raw |>
    group_by(trains) |>
    summarise(timeouts = sum(.data[[STATUS_COL]] == "out of time"), .groups = "drop")
  
  # Averages over ok rows only
  avg <- raw |>
    group_by(trains) |>
    summarise(
      grounding   = mean(`overall-time` - `solving-time`, na.rm = TRUE),
      global      = mean(`overall-time`,                  na.rm = TRUE),
      rules       = mean(rules,                           na.rm = TRUE),
      variables   = mean(variables,                       na.rm = TRUE),
      constraints = mean(constraints,                     na.rm = TRUE),
      .groups     = "drop"
    ) |>
    left_join(timeout_counts, by = "trains")
  
  # Prefix all metric columns with the suffix
  avg |>
    rename_with(~ paste0(suffix, "-", .x), -trains)
}

# ── Build combined table ───────────────────────────────────────────────────────

combined <- SUFFIXES |>
  map(process_experiment) |>
  reduce(full_join, by = "trains") |>
  arrange(trains) |>
  mutate(instances = instances_for(trains)) |>
  select(trains, instances, everything())

write.csv(combined, file="averages-mc-verify")
View(combined)
