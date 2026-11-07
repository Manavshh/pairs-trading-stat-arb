library(DBI)
library(RSQLite)
library(tseries)
library(reshape2)

con <- dbConnect(RSQLite::SQLite(), "stock_data.db")
all_prices <- dbGetQuery(con, "SELECT date, ticker, close FROM prices ORDER BY date")
dbDisconnect(con)

wide <- dcast(all_prices, date ~ ticker, value.var = "close")
wide <- wide[order(wide$date), ]
wide <- wide[, colSums(is.na(wide)) == 0]      # keep tickers with no gaps

lp <- log(as.matrix(wide[, -1]))
n_train <- floor(0.7 * nrow(lp))               # pick pairs on the first 70% only
train <- lp[1:n_train, ]

pairs <- t(combn(colnames(train), 2))
results <- data.frame(stock1 = pairs[, 1], stock2 = pairs[, 2],
                      p_value = NA_real_, hedge = NA_real_)

for (i in seq_len(nrow(pairs))) {
  y <- train[, pairs[i, 1]]
  x <- train[, pairs[i, 2]]
  results$hedge[i]   <- coef(lm(y ~ x))[2]
  results$p_value[i] <- tryCatch(po.test(cbind(y, x))$p.value,
                                 error = function(e) NA)
}

results$p_adj <- p.adjust(results$p_value, method = "BH")
results <- results[order(results$p_value), ]

cat("\ntickers:", ncol(train), " train rows:", n_train, " of ", nrow(lp), "\n")
cat("pairs tested:", nrow(results), "\n")
cat("raw p < 0.05:", sum(results$p_value < 0.05, na.rm = TRUE), "\n")
cat("adjusted p < 0.05:", sum(results$p_adj < 0.05, na.rm = TRUE), "\n\n")
print(head(results, 15))

cat("\nPairs chosen from economic logic:\n")
print(results[results$stock1 %in% c("MA", "CVX", "HD", "KO") &
              results$stock2 %in% c("V", "XOM", "LOW", "PEP"), ])

write.csv(results, "all_pairs_scan.csv", row.names = FALSE)