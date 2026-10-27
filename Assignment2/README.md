# BDA400 Assignment 2 — Technical Analysis using R (Preliminary Stage)

**Student:** Sriteja Kokkula | **Student ID:** 664429563  
**GitHub repository:** https://github.com/Sriteja490/TechnicalAnalysis

> Repository URL is the **intended URL**. Create the GitHub repository named
> `TechnicalAnalysis` and confirm the link works before submitting.

## Project contents

```
TechnicalAnalysis/
  README.md
  Assignment2/
    README.md
    portfolio.txt
    R/
      technical_analysis.R
      display_results.R
      run_analysis.R
    docs/
      SritejaKokkula_BDA400_A02.docx
      SritejaKokkula_BDA400_A02_Cover.docx
      screenshots/                 # prior setup evidence + new captures
    outputs/                       # populated when you run R
```

## Prerequisites

- Windows R 4.6.1 / RStudio Desktop (or compatible recent versions)
- Internet connection to download live market data from Yahoo Finance
- R packages: `quantmod`, `TTR`, `ggplot2`, `zoo`

## Install dependencies in the RStudio Console

```r
install.packages(c("quantmod", "TTR", "ggplot2", "zoo"))
```

## Run this assignment

1. Extract the ZIP file on your PC.
2. In RStudio, choose **Session > Set Working Directory > Choose Directory**.
3. Choose the **`TechnicalAnalysis/Assignment2`** folder (not the `R` folder).
4. In the RStudio Console, enter:

```r
source("R/run_analysis.R")
```

5. Wait for Yahoo Finance downloads, inspect the Console tables, and open
   `outputs/` to see stock data, a summary CSV and PNG charts.
6. Capture **your own screenshots of your actual run and the new GitHub repo**.
   Add these to the marked boxes in the Word report, save it, and upload it.

## Portfolio selection

`portfolio.txt` lists example tickers `AAPL`, `MSFT`, and `GOOGL`, one per line.
Replace them with stocks of your choice if required by the instructor.

## How the statistics work

- **Mean**: average of observed daily closing prices (USD).
- **Mode**: most frequent closing price rounded to cents; `NA` when there are
  no repeated closing prices. Ties choose the smallest repeated value.
- **Median**: middle daily closing price.
- **Standard deviation**: sample standard deviation of daily closing prices.
- **Moving average**: simple average over 20 trading-day closes; the first
  19 values are `NA`, as there is no complete 20-day window.

Yahoo Finance's historical data are subject to revisions and availability.
The import function skips unavailable tickers with a warning; at least one
successful ticker is required.

## Deliverables

- MS Word assignment report with step-by-step screenshots (`docs/...Report.docx`)
- MS Word cover page with repository URL (`docs/...Cover.docx`)
- `portfolio.txt` (stock symbols, one symbol per line)
- R functions for Yahoo Finance download and required five statistics
- R data display, visualizations, and optional CSV/PNG output

**Academic integrity:** Report screenshots must show the user's real local
installation, live run, and actual GitHub repository. No illustrative image
may be presented as evidence of an event that did not occur.
