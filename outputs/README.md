# Generated outputs

After running `source("R/run_analysis.R")` in RStudio, this folder receives:

- `stock_statistics.csv` — one row per successfully downloaded ticker
- `<TICKER>_daily.csv` — daily OHLCV data plus 20-day SMA
- `<TICKER>_price_and_SMA.png` — line chart of Close and 20-day moving average

All output depends on live Yahoo Finance availability and today's date.
Screenshots of these actual output files belong in the Word assignment report.
