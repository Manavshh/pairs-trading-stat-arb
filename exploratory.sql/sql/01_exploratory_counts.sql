SELECT ticker, COUNT(*) as num_days
FROM prices
GROUP BY ticker
ORDER BY ticker;