# One-Predictor Linear Regression: Missing Data Imputation & Model Fitting

Statistical analysis project for **AMS 315 (Data Analysis), Stony Brook University, Fall 2026**, done in R.

## Overview

**Part A: data cleaning and missing data.** Two files (independent variable and dependent variable, keyed by subject ID) are sorted and merged programmatically. I count the missing values in each variable and fill them in with multiple imputation (`mice`, bootstrap linear regression). A simple linear regression is then fitted to the completed data.

**Part B: model recovery.** The goal is to recover the function that generated the dependent variable. I compare variable transformations by R² and by residual diagnostics. Near-repeated x values are binned so that an approximate lack-of-fit (pure error) F-test can be run on the chosen model.

## Skills demonstrated
- Data wrangling: merging keyed datasets, auditing missing data
- Multiple imputation (MICE)
- OLS regression: ANOVA, confidence intervals, hypothesis testing on the slope
- Regression diagnostics: residual analysis, variable transformations (Box-Cox style)
- Lack-of-fit testing with binned replicates

## Repo layout
```
run_all.R        runs the full analysis and saves all console output
R/partA.R        merge, missing-data audit, imputation, regression
R/partB.R        transformation search, regression, binning, LOF test
data/            input data (anonymized file names) + merged/imputed CSVs
figures/         plots produced by the scripts
output/          full console output from each part (partA_output.txt, partB_output.txt)
report/          final write-up (PDF)
```

## How to run
1. Install R and RStudio.
2. Open the project folder in RStudio and install the packages (one time only):
   ```r
   install.packages(c("mice", "remotes"))
   remotes::install_github("cran/alr3")
   ```
3. Open `run_all.R` and click **Source**. It reproduces every result in one step:
   - runs `R/partA.R` and then `R/partB.R`
   - saves the merged and imputed data to `data/`
   - saves all plots to `figures/`
   - records the full printed output (tables, model summaries, tests) to `output/`

A fixed random seed (`set.seed(315)`) makes the imputation results reproducible.

## Key results
<!-- Fill in after you finish, e.g.:
- Part A: N subjects, X% IV missing, Y% DV missing; fitted DV = a + b·IV, R² = ...
- Part B: best model was ..., R² improved from ... to ...; LOF p = ...
-->
