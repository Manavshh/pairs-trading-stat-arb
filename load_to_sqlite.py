import pandas as pd
import sqlite3

# yfinance saves multi-ticker data with a 2-row header (metric, ticker)
df = pd.read_csv("data/stock_prices.csv", header=[0, 1], index_col=0)
df.index.name = "Date"

# Reshape from wide format into long format: one row per date+ticker
df = df.stack(level=1).reset_index()
df.columns.name = None
df = df.rename(columns={"level_1": "Ticker"})

# Clean column names to lowercase for easier SQL querying
df.columns = [c.lower() for c in df.columns]

print(df.head())
print(df.shape)

# Load into SQLite
conn = sqlite3.connect("stock_data.db")
df.to_sql("prices", conn, if_exists="replace", index=False)
conn.close()

print("Loaded into stock_data.db, table 'prices'")