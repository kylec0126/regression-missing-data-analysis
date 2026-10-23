# =============================================================
# AMS 315 - Project 1, Part B
# Find a transformation, fit regression, bin x, lack-of-fit test
# =============================================================

# Run once to install alr3 (provides pureErrorAnova):
# install.packages("remotes")
# remotes::install_github("cran/alr3")   # if asked to update packages, type 3
library(alr3)

dat <- read.csv("data/partB.csv", header = TRUE)
str(dat)
summary(dat)

# ---- 1. Look at the raw data ---------------------------------
M0 <- lm(y ~ x, data = dat)
summary(M0)$r.squared            # baseline R-squared

png("figures/partB_raw.png", width = 1000, height = 450)
par(mfrow = c(1, 2))
plot(y ~ x, data = dat, pch = 20, main = "Raw: y vs x"); abline(M0, col = "red")
plot(fitted(M0), resid(M0), pch = 20, main = "Raw: residuals vs fitted"); abline(h = 0)
dev.off()

# ---- 2. Try candidate transformations (textbook 11.1) --------
# Compare R-squared for each combination. Also LOOK at each
# residual plot -- the best choice is the one whose residuals
# look patternless with roughly constant spread.
tx <- list(x = function(v) v, `log(x)` = log, `1/x` = function(v) 1/v,
           `sqrt(x)` = sqrt, `x^2` = function(v) v^2)
ty <- list(y = function(v) v, `log(y)` = log, `1/y` = function(v) 1/v,
           `sqrt(y)` = sqrt, `1/sqrt(y)` = function(v) 1/sqrt(v))
r2 <- outer(names(tx), names(ty), Vectorize(function(a, b) {
  summary(lm(ty[[b]](dat$y) ~ tx[[a]](dat$x)))$r.squared
}))
dimnames(r2) <- list(names(tx), names(ty))
round(r2, 4)

# Box-Cox on y can suggest a power (lambda): -1 = 1/y, 0 = log(y), 0.5 = sqrt(y)
# library(MASS); boxcox(M0)

# ---- 3. Fit your chosen model --------------------------------
# >>> EDIT these two lines to the transformation you picked <<<
dat$xt <- dat$x
dat$yt <- 1 / dat$y

M1 <- lm(yt ~ xt, data = dat)
summary(M1)
anova(M1)
confint(M1, level = 0.95)

png("figures/partB_transformed.png", width = 1000, height = 450)
par(mfrow = c(1, 2))
plot(yt ~ xt, data = dat, pch = 20, main = "Transformed"); abline(M1, col = "red")
plot(fitted(M1), resid(M1), pch = 20, main = "Transformed: residuals vs fitted"); abline(h = 0)
dev.off()

# ---- 4. Bin near-repeated x values ---------------------------
# Cut x into intervals; every x in an interval is replaced by the
# interval's mean x. Pick a width so each bin has a decent number
# of points (check table(groups)).
width  <- 0.05
groups <- cut(dat$xt,
              breaks = c(-Inf,
                         seq(min(dat$xt) + width, max(dat$xt) - width, by = width),
                         Inf))
table(groups)
dat$x_bin <- ave(dat$xt, groups)       # mean x within each bin

# ---- 5. Lack-of-fit test -------------------------------------
fit_bin <- lm(yt ~ x_bin, data = dat)
pureErrorAnova(fit_bin)
# Large p-value on the "Lack of fit" row => no evidence the straight
# line is the wrong shape for the transformed data.

# Optional: run the same LOF on the UNtransformed data for comparison
dat$x_bin_raw <- ave(dat$x, cut(dat$x, breaks = c(-Inf,
                     seq(min(dat$x) + width, max(dat$x) - width, by = width), Inf)))
pureErrorAnova(lm(y ~ x_bin_raw, data = dat))

