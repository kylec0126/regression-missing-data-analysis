# Runs the full analysis and saves all printed output to output/
dir.create("output", showWarnings = FALSE)

sink("output/partA_output.txt", split = TRUE)
source("R/partA.R", echo = TRUE)
sink()

sink("output/partB_output.txt", split = TRUE)
source("R/partB.R", echo = TRUE)
sink()
