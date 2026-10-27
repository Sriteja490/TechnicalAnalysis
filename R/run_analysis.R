# BDA400 Assignment 2: Main script
# BEFORE RUNNING: Set RStudio's working directory to the Assignment2 folder.
# RStudio menu: Session > Set Working Directory > Choose Directory
# Then in the Console run: source("R/run_analysis.R")

packages <- c("quantmod", "TTR", "ggplot2", "zoo")
missing_packages <- packages[!vapply(packages, requireNamespace,
                                     logical(1), quietly = TRUE)]
if (length(missing_packages) > 0) {
  stop("Install required packages first: install.packages(c(",
       paste(sprintf('"%s"', missing_packages), collapse = ", "), "))")
}
if (!file.exists("portfolio.txt")) {
  stop("Cannot find portfolio.txt. Set working directory to Assignment2, then retry.")
}
source(file.path("R", "technical_analysis.R"))
source(file.path("R", "display_results.R"))

# Stage 1: load the stock portfolio over the last ~one calendar year.
stock_data <- load_stock_data("portfolio.txt", from = Sys.Date() - 365,
                              to = Sys.Date())
message("Successfully downloaded symbols: ", paste(names(stock_data), collapse = ", "))
failed <- attr(stock_data, "failed_symbols")
if (length(failed) > 0L) message("Unsuccessful symbols: ", paste(failed, collapse = ", "))

# Stage 2: preview each imported stock's independent data frame.
display_stock_data(stock_data)

# Stage 3: compute mean, mode, median, standard deviation, and 20-day SMA.
ma_period <- 20L
analysis <- calculate_portfolio_statistics(stock_data, ma_period = ma_period)
display_statistics(analysis$summary)

# Stage 4: export summary and charts for the report.
dir.create("outputs", showWarnings = FALSE, recursive = TRUE)
utils::write.csv(analysis$summary, file = "outputs/stock_statistics.csv",
                 row.names = FALSE, na = "")
for (symbol in names(analysis$by_stock)) {
  utils::write.csv(analysis$by_stock[[symbol]],
                   file = file.path("outputs", paste0(symbol, "_daily.csv")),
                   row.names = FALSE, na = "")
}
save_stock_charts(analysis$by_stock, output_dir = "outputs", ma_period = ma_period)
message("Complete. Results saved in Assignment2/outputs.")
