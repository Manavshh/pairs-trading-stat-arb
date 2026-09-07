WITH ko_ma AS (
    SELECT date, close,
           AVG(close) OVER (ORDER BY date ROWS BETWEEN 19 PRECEDING AND CURRENT ROW) AS ma_20,
           AVG(close) OVER (ORDER BY date ROWS BETWEEN 49 PRECEDING AND CURRENT ROW) AS ma_50
    FROM prices
    WHERE ticker = 'KO'
)
SELECT * FROM ko_ma
ORDER BY date DESC
LIMIT 20;