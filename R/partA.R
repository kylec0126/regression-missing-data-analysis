# =============================================================
# AMS 315 - Project 1, Part A
# Merge IV + DV files by subject ID, count missing data, impute
# Run from the project folder (open ams315-project1.Rproj or setwd() to it)
# =============================================================

# install.packages("mice")   # run once
library(mice)

set.seed(315)   # makes the imputation reproducible

# ---- 1. Read the two files ----------------------------------
iv <- read.csv("data/partA_IV.csv", header = TRUE)
dv <- read.csv("data/partA_DV.csv", header = TRUE)
str(iv); str(dv)

# ---- 2. Sort by ID and merge (NOT cut-and-paste) ------------
# all = TRUE is a FULL outer join: keeps an ID even if it only
# appears in one file, so no subjects are silently dropped.
iv <- iv[order(iv$ID), ]
dv <- dv[order(dv$ID), ]
partA <- merge(iv, dv, by = "ID", all = TRUE)
str(partA)
write.csv(partA, "data/partA_merged.csv", row.names = FALSE)

# ---- 3. Counts the report asks for --------------------------
n_total   <- nrow(partA)
has_iv    <- !is.na(partA$IV)
has_dv    <- !is.na(partA$DV)

counts <- data.frame(
  Quantity = c("Total subject IDs",
               "IDs with an IV value",
               "IDs with a DV value",
               "IDs with both IV and DV",
               "IDs with at least one of IV or DV",
               "IDs missing both",
               "Fraction of IV missing",
               "Fraction of DV missing"),
  Value = c(n_total,
            sum(has_iv),
            sum(has_dv),
            sum(has_iv & has_dv),
            sum(has_iv | has_dv),
            sum(!has_iv & !has_dv),
            round(mean(!has_iv), 4),
            round(mean(!has_dv), 4))
)
print(counts)
md.pattern(partA)   # visual missing-data pattern (good for the appendix)

# ---- 4. Drop rows with NO information, then impute ----------
partA_imp <- partA[has_iv | has_dv, ]

# norm.boot = linear regression imputation with bootstrap.
# Other allowed choices: "pmm" (predictive mean matching), "norm".
# NOT allowed: mean, median, listwise deletion.
imp <- mice(partA_imp[, c("IV", "DV")], method = "norm.boot",
            m = 5, printFlag = FALSE)
partA_complete <- cbind(ID = partA_imp$ID, complete(imp))
md.pattern(partA_complete)   # should say "completely observed"
write.csv(partA_complete, "data/partA_imputed.csv", row.names = FALSE)

# ---- 5. Regression on the completed data --------------------
M <- lm(DV ~ IV, data = partA_complete)
summary(M)
anova(M)
confint(M, level = 0.95)

png("figures/partA_scatter.png", width = 700, height = 500)
plot(DV ~ IV, data = partA_complete, pch = 20,
     main = "Figure 1: DV vs IV (after imputation)")
abline(M, col = "red", lwd = 2)
dev.off()
