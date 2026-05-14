### In this file, we analyze the raw data
### and produce initial visualizations
### for time and for timeouts.

library(readxl)
library(dplyr)
library(purrr)
library(tidyr)

# ── Configuration ────────────────────────────────────────────────────────────

BASE_PATH   <- "~/git/flaspland-encodings/benchmarking/"
FILE_PREFIX <- "results-dist-"
SUFFIXES    <- c("ba", "ma", "de", "ds", "dh", "me", "ms", "mh")   # extend as needed

# Column positions (adjust if structure shifts)
TRAINS_COL_IDX    <- 1   # the column from which we extract the train count
TRAINS_CHAR_POS   <- 9  # character position within that string
STATUS_COL        <- "rstatus"

# ── Helper: extract train count from instance name ───────────────────────────

extract_trains <- function(df) {
  raw <- pull(df, TRAINS_COL_IDX)          # keep as character
  as.integer(substr(raw, TRAINS_CHAR_POS, TRAINS_CHAR_POS))
}

# ── Helper: process a single file ────────────────────────────────────────────

process_file <- function(suffix) {
  path <- file.path(BASE_PATH, paste0(FILE_PREFIX, suffix, ".xlsx"))
  
  raw <- read_excel(path, skip = 1) |>
    select(1:18) |> 
    mutate(trains = extract_trains(pick(everything())))
  
  # Timeout summary
  timeouts <- raw |>
    group_by(trains) |>
    summarise(
      n_timeout = sum(.data[[STATUS_COL]] == "out of time"),
      n_total   = n(),
      .groups   = "drop"
    )
  
  # Filtered: ok rows only
  ok <- raw |>
    filter(.data[[STATUS_COL]] == "ok")
  
  # Aggregations grouped by trains
  # Adjust the columns in across() to whichever numeric metrics you care about
  numeric_cols <- ok |> select(where(is.numeric), -trains) |> names()
  
  make_agg <- function(data, fns) {
    data |>
      group_by(trains) |>
      summarise(across(all_of(numeric_cols), fns, .names = "{.col}"), .groups = "drop")
  }
  
  list(
    raw      = raw,
    ok       = ok,
    timeouts = timeouts,
    avg      = make_agg(ok, list(mean  = \(x) mean(x,   na.rm = TRUE))),
    min      = make_agg(ok, list(min   = \(x) min(x,    na.rm = TRUE))),
    max      = make_agg(ok, list(max   = \(x) max(x,    na.rm = TRUE))),
    sd       = make_agg(ok, list(sd    = \(x) sd(x,     na.rm = TRUE)))
  )
}

# ── Process all files ─────────────────────────────────────────────────────────

results <- set_names(SUFFIXES) |> map(process_file)

# Access individual results cleanly:
#   results[["ba"]]$avg
#   results[["ma"]]$timeouts

# ── Combined tables (one row per suffix × trains combination) ─────────────────

combined_timeouts <- map(results, "timeouts") |> bind_rows(.id = "source")
combined_avg      <- map(results, "avg")      |> bind_rows(.id = "source")
combined_min      <- map(results, "min")      |> bind_rows(.id = "source")
combined_max      <- map(results, "max")      |> bind_rows(.id = "source")
combined_sd       <- map(results, "sd")       |> bind_rows(.id = "source")


# ── Visualize results ─────────────────────────────────────────────────────────

library(ggplot2)

# ── Configuration ─────────────────────────────────────────────────────────────

METRIC  <- "overall-time"   # change to any column name from combined_avg
USE_LOG <- F            # TRUE for log10 y-axis, FALSE for linear

# ── Aesthetic mappings ────────────────────────────────────────────────────────

line_colors <- c(
  ds = "#E07B39", de = "#E07B39", dh = "#E07B39",
  ms = "#2E8B4A", me = "#2E8B4A", mh = "#2E8B4A",
  ba = "#888888",
  ma = "#3A6FBF"
)

line_types <- c(
  ds = "solid", ms = "solid",
  de = "22",    me = "22",
  dh = "88",    mh = "88",
  ba = "solid",
  ma = "solid"
)

# ── Line chart ────────────────────────────────────────────────────────────────

p <- ggplot(combined_avg, aes(x = trains, y = .data[[METRIC]],
                              color = source, linetype = source, group = source)) +
  geom_line(linewidth = 0.8) +
  geom_point(size = 2) +
  scale_x_continuous(breaks = sort(unique(combined_avg$trains))) +
  scale_color_manual(values = line_colors) +
  scale_linetype_manual(values = line_types) +
  labs(
    x        = "Number of trains",
    y        = if (USE_LOG) paste0(METRIC, " (log scale)") else METRIC,
    color    = "Encoding",
    linetype = "Encoding",
    title    = paste("Average", METRIC, "by number of trains")
  ) +
  theme_minimal(base_size = 13) +
  theme(legend.position = "bottom")

if (USE_LOG) {
  p <- p + scale_y_log10()
}

print(p)

# ── Bar chart ─────────────────────────────────────────────────────────────────
# Timeouts
ggplot(combined_timeouts, aes(x = factor(trains), y = n_timeout, fill = source)) +
  geom_col() +
  geom_text(aes(label = ifelse(n_timeout > 0, n_timeout, "")),
            vjust = -0.4, size = 3) +
  facet_wrap(~ source, nrow = 2) +
  scale_fill_manual(values = line_colors) +
  labs(
    x     = "Number of trains",
    y     = "Timeouts",
    fill  = "Encoding",
    title = "Timeouts by encoding and number of trains"
  ) +
  theme_minimal(base_size = 12) +
  theme(legend.position = "none")   # redundant with facet labels

# ── Save files ────────────────────────────────────────────────────────────────
write.csv(combined_avg, file = "combined_avg.csv")
write.csv(combined_timeouts, file = "combined_timeouts.csv")
