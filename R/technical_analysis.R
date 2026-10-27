# BDA400 Assignment 2: Technical Analysis using R - Preliminary Stage
# Student: Sriteja Kokkula | Student ID: 664429563
# File: R/technical_analysis.R
# Tasks: read portfolio.txt, import Yahoo Finance OHLCV, compute statistics.
# Reproducibility: imports live data, so results change by date and provider.

# 1. Load/validate portfolio stock symbols ------------------------------
read_portfolio <- function(file = "portfolio.txt") {
  if (!file.exists(file)) stop("Missing portfolio file: ", file)
  tickers <- trimws(readLines(file, warn = FALSE))
  tickers <- tickers[nzchar(tickers) & !startsWith(tickers, "#")]
  tickers <- unique(toupper(tickers))
  if (length(tickers) == 0L) stop("portfolio.txt must contain one or more tickers")
  if (any(!grepl("^[A-Z0-9.^_-]+$", tickers))) {
    stop("Invalid ticker format. Use one symbol per line, e.g. AAPL")
  }
  tickers
}

# 2. Yahoo Finance data download ----------------------------------------
# Returns one separate data frame per ticker in a named list.
# quantmod::getSymbols retrieves live historical market data over the internet.
load_stock_data <- function(portfolio_file = "portfolio.txt",
                            from = Sys.Date() - 365,
                            to = Sys.Date()) {
  if (!requireNamespace("quantmod", quietly = TRUE)) {
    stop("Package quantmod is missing. Run install.packages('quantmod')")
  }
  if (!requireNamespace("zoo", quietly = TRUE)) {
    stop("Package zoo is missing. Run install.packages('zoo')")
  }
  from <- as.Date(from)
  to <- as.Date(to)
  if (is.na(from) || is.na(to) || from >= to) {
    stop("Choose valid from/to dates with from < to")
  }

  symbols <- read_portfolio(portfolio_file)
  stock_data <- list()
  failures <- character()

  for (symbol in symbols) {
    message("Downloading ", symbol, " from Yahoo Finance ...")
    series <- tryCatch(
      quantmod::getSymbols(Symbols = symbol, src = "yahoo", from = from,
                           to = to, auto.assign = FALSE),
      error = function(err) {
        warning("Unable to download ", symbol, ": ", conditionMessage(err),
                call. = FALSE)
        NULL
      }
    )
    if (is.null(series) || NROW(series) == 0L) {
      failures <- c(failures, symbol)
      next
    }

    adjusted <- tryCatch(as.numeric(quantmod::Ad(series)),
                         error = function(err) as.numeric(quantmod::Cl(series)))
    stock <- data.frame(
      Date = as.Date(zoo::index(series)),
      Open = as.numeric(quantmod::Op(series)),
      High = as.numeric(quantmod::Hi(series)),
      Low = as.numeric(quantmod::Lo(series)),
      Close = as.numeric(quantmod::Cl(series)),
      Volume = as.numeric(quantmod::Vo(series)),
      Adjusted = adjusted,
      Symbol = symbol,
      stringsAsFactors = FALSE
    )
    stock <- stock[!is.na(stock$Date) & is.finite(stock$Close), , drop = FALSE]
    stock <- stock[order(stock$Date), , drop = FALSE]
    rownames(stock) <- NULL
    if (nrow(stock) == 0L) {
      failures <- c(failures, symbol)
      next
    }
    stock_data[[symbol]] <- stock
  }
  attr(stock_data, "failed_symbols") <- failures
  if (length(stock_data) == 0L) {
    stop("No stock data was downloaded. Check internet, Yahoo Finance, dates, and symbols.")
  }
  stock_data
}

# 3. Numeric mode for stock prices --------------------------------------
# Close prices are rounded to cents. When no price repeats, mode is NA.
# In a tie, the smallest equally frequent value is returned consistently.
mode_price <- function(x) {
  x <- round(as.numeric(x), 2)
  x <- x[is.finite(x)]
  if (length(x) == 0L) return(NA_real_)
  frequency <- table(x)
  if (max(frequency) <= 1L) return(NA_real_)
  candidates <- as.numeric(names(frequency)[frequency == max(frequency)])
  min(candidates)
}

# 4. Basic statistics and 20-day moving average -------------------------
calculate_statistics <- function(stock_df, ma_period = 20L) {
  if (!requireNamespace("TTR", quietly = TRUE)) {
    stop("Package TTR is missing. Run install.packages('TTR')")
  }
  if (!is.data.frame(stock_df) || !all(c("Date", "Close", "Symbol") %in% names(stock_df))) {
    stop("Expected a stock data frame with Date, Close and Symbol columns")
  }
  ma_period <- as.integer(ma_period)
  if (length(ma_period) != 1L || is.na(ma_period) || ma_period < 2L) {
    stop("ma_period must be an integer >= 2")
  }
  stock_df <- stock_df[order(stock_df$Date), , drop = FALSE]
  price <- as.numeric(stock_df$Close)
  valid_price <- price[is.finite(price)]
  if (length(valid_price) == 0L) stop("No valid Close values")
  if (any(!is.finite(price))) stop("Close prices must be finite")

  # TTR::SMA produces NA for the initial n-1 rows (by definition).
  sma <- if (length(price) >= ma_period) {
    as.numeric(TTR::SMA(price, n = ma_period))
  } else {
    rep(NA_real_, length(price))
  }
  stock_df$SMA_20 <- sma  # default period 20; set different ma_period if desired
  result <- data.frame(
    Symbol = unique(stock_df$Symbol)[1],
    Observations = length(valid_price),
    Latest_Date = as.character(tail(stock_df$Date, 1)),
    Latest_Close = tail(price, 1),
    Mean = mean(valid_price),
    Mode = mode_price(valid_price),
    Median = median(valid_price),
    Std_Dev = if (length(valid_price) >= 2L) sd(valid_price) else NA_real_,
    Moving_Average_Period = ma_period,
    Latest_Moving_Average = tail(sma, 1),
    stringsAsFactors = FALSE
  )
  list(data = stock_df, summary = result)
}

# 5. Apply statistics separately to each stock --------------------------
calculate_portfolio_statistics <- function(stock_data, ma_period = 20L) {
  if (!is.list(stock_data) || length(stock_data) == 0L) stop("Empty stock data")
  detailed <- lapply(stock_data, calculate_statistics, ma_period = ma_period)
  summary <- do.call(rbind, lapply(detailed, `[[`, "summary"))
  rownames(summary) <- NULL
  list(by_stock = lapply(detailed, `[[`, "data"), summary = summary)
}
