# Statistical Arbitrage — Pairs Trading

Finding cointegrated stock pairs and testing whether they stay cointegrated out of sample. A mean-reversion backtest with transaction costs is in progress.

**Stack:** SQL (SQLite) for signal generation · R for cointegration testing & backtesting · Tableau/Power BI for the dashboard

## Status: In progress: 

scan and out-of-sample check done. Backtest next.

## Results so far : 

36 pairs tested on the first 70% of the data. 13 had p < 0.05 (about 7 expected by chance). None survived multiple-testing correction. Three economically related pairs (MA/V, KO/PEP, HD/LOW) did not stay cointegrated on the held-out 30%.
