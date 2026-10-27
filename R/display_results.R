# BDA400 Assignment 2: Display utilities and plots
# Functions display imported data, summary tables, and line charts with SMA.

display_stock_data <- function(stock_data, preview_rows = 5L) {
  for (ticker in names(stock_data)) {
    cat("\n", strrep("-", 55), "\n", ticker,
        " | First and last observations\n", sep = "")
    print(utils::head(stock_data[[ticker]], preview_rows), row.names = FALSE)
    cat("... latest observations ...\n")
    print(utils::tail(stock_data[[ticker]], preview_rows), row.names = FALSE)
  }
  invisible(stock_data)
}

display_statistics <- function(summary_table) {
  cat("\nStock portfolio statistics (USD per share)\n")
  print(summary_table, row.names = FALSE, digits = 5)
  invisible(summary_table)
}

plot_stock_data <- function(stock_df, ma_period = 20L) {
  if (!requireNamespace("ggplot2", quietly = TRUE)) {
    stop("Package ggplot2 is missing. Run install.packages('ggplot2')")
  }
  ticker <- as.character(stock_df$Symbol[1])
  ggplot2::ggplot(stock_df, ggplot2::aes(x = Date)) +
    ggplot2::geom_line(ggplot2::aes(y = Close, color = "Daily close"),
                       linewidth = 0.65) +
    ggplot2::geom_line(ggplot2::aes(y = SMA_20, color = "Moving average"),
                       linewidth = 0.9, na.rm = TRUE) +
    ggplot2::scale_color_manual(
      values = c("Daily close" = "#225AA8", "Moving average" = "#E17C2C")
    ) +
    ggplot2::labs(
      title = paste0(ticker, " | Historical closing price"),
      subtitle = paste0(ma_period, "-trading-day simple moving average"),
      x = "Trading date", y = "Price (USD)", color = "Series",
      caption = "Data: Yahoo Finance via quantmod. For educational use."
    ) +
    ggplot2::theme_minimal(base_size = 12) +
    ggplot2::theme(legend.position = "bottom")
}

save_stock_charts <- function(detailed_data, output_dir = "outputs", ma_period = 20L) {
  dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
  for (symbol in names(detailed_data)) {
    chart <- plot_stock_data(detailed_data[[symbol]], ma_period = ma_period)
    output_file <- file.path(output_dir, paste0(symbol, "_price_and_SMA.png"))
    ggplot2::ggsave(output_file, plot = chart, width = 9, height = 5,
                    units = "in", dpi = 150)
    message("Saved chart: ", normalizePath(output_file))
  }
  invisible(TRUE)
}
