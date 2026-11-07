library(DBI); library(RSQLite); library(tseries); library(reshape2)

con <- dbConnect(RSQLite::SQLite(), "stock_data.db")
d <- dbGetQuery(con, "SELECT date, ticker, close FROM prices ORDER BY date")
dbDisconnect(con)
wide <- dcast(d, date ~ ticker, value.var = "close")
wide <- wide[order(wide$date), ]
wide <- wide[, colSums(is.na(wide)) == 0]
lp <- log(as.matrix(wide[, -1]))
n_train <- floor(0.7 * nrow(lp))

half_life <- function(s) {
  phi <- coef(lm(s[-1] ~ s[-length(s)]))[2]
  if (phi > 0 && phi < 1) -log(2) / log(phi) else NA
}

pairs <- list(c("MA","V"), c("KO","PEP"), c("HD","LOW"))
for (p in pairs) {
  y <- lp[, p[1]]; x <- lp[, p[2]]
  tr <- 1:n_train; te <- (n_train + 1):nrow(lp)
  fit <- lm(y[tr] ~ x[tr])
  a <- coef(fit)[1]; b <- coef(fit)[2]
  s_tr <- y[tr] - (a + b * x[tr])
  s_te <- y[te] - (a + b * x[te])
  z_te <- (s_te - mean(s_tr)) / sd(s_tr)
  cat("\n", p[1], "/", p[2], "\n")
  cat("  hedge ratio (from train):", round(b, 3), "\n")
  cat("  half-life, train (days):", round(half_life(s_tr), 1), "\n")
  cat("  half-life, test  (days):", round(half_life(s_te), 1), "\n")
  cat("  ADF p-value on held-out spread:", round(suppressWarnings(adf.test(s_te)$p.value), 3), "\n")
  cat("  held-out spread mean in train sds:", round(mean(z_te), 2), "\n")
  cat("  days with |z| > 2 in held-out:", round(100 * mean(abs(z_te) > 2)), "%\n")
}