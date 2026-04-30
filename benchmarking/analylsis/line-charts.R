### In this file, we take the aggregated data
### and produce a simple visualization.

library(readxl)

# ── Configuration ─────────────────────────────────────────────────────────────

path  <- file.path("~/git/flaspland-encodings/benchmarking/analylsis/averages.xlsx")
raw   <- read_excel(path, sheet = "tall")

# ── Line charts ───────────────────────────────────────────────────────────────
 
# Overall time
par(mar = c(5, 9, 3, 3))
plot(x = 2:7, y = raw$global[raw$setting == "mapf"], 
     type = "l", lty = 1, lwd = 2,
     axes = FALSE, xlab = "Trains", ylab = "",
     xaxt="n", yaxt="n")
mtext("Seconds", side = 2, line = 4, las = 1)
lines(x = 2:7, y = raw$global[raw$setting == "drive-edge"], 
      type = "l", lty = 2, lwd = 2)
lines(x = 2:7, y = raw$global[raw$setting == "drive-subnodes"], 
      type = "l", lty = 3, lwd = 2)
lines(x = 2:7, y = raw$global[raw$setting == "drive-hyper"], 
      type = "l", lty = 4, lwd = 2)
axis(side = 1, tcl = 0, line = TRUE)
axis(side = 2, tcl = 0, line = TRUE, las = 2)
legend(2, 1500, c("mapf", "edge functions", "subnodes", "hypergraph"), 
       lty = c(1,2,3,4), lwd = c(2,2,2,2))

# Grounding time
par(mar = c(5, 9, 3, 3))
plot(x = 2:7, y = raw$grounding[raw$setting == "mapf"], 
     type = "l", lty = 1, lwd = 2,
     axes = FALSE, xlab = "Trains", ylab = "",
     xaxt = "n", yaxt = "n", ylim = c(0,300))
mtext("Seconds", side = 2, line = 4, las = 1)
lines(x = 2:7, y = raw$grounding[raw$setting == "drive-edge"], 
      type = "l", lty = 2, lwd = 2)
lines(x = 2:7, y = raw$grounding[raw$setting == "drive-subnodes"], 
      type = "l", lty = 3, lwd = 2)
lines(x = 2:7, y = raw$grounding[raw$setting == "drive-hyper"], 
      type = "l", lty = 4, lwd = 2)
axis(side = 1, tcl = 0, line = TRUE, at = 2:7)
axis(side = 2, tcl = 0, line = TRUE, las = 2)
legend(2, 300, c("mapf", "edge functions", "subnodes", "hypergraph"), 
       lty = c(1,2,3,4), lwd = c(2,2,2,2))