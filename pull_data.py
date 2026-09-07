import yfinance as yf
from datetime import date

tickers = [
    "KO", "PEP",              # Consumer staples
    "V", "MA", "AXP",         # Payments
    "JPM", "BAC", "WFC", "C", # Banks
    "XOM", "CVX",             # Energy
    "GOOGL", "META", "AAPL", "MSFT",  # Big tech
    "HD", "LOW"                # Retail
]

data = yf.download(tickers, start="2018-01-01", end=date.today().strftime("%Y-%m-%d"))
data.to_csv("data/stock_prices.csv")
print("Saved", data.shape, "rows/cols to data/stock_prices.csv")