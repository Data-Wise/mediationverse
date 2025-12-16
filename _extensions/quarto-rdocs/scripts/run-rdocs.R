#!/usr/bin/env Rscript
#' Run quarto-rdocs manually
#'
#' Usage:
#'   Rscript _extensions/quarto-rdocs/scripts/run-rdocs.R
#'
#' Or from R:
#'   source("_extensions/quarto-rdocs/scripts/run-rdocs.R")

# Ensure we're in the package root
if (!file.exists("DESCRIPTION")) {
  stop("Please run this script from the package root directory")
}

# Check for required packages
required_pkgs <- c("yaml", "tools")
missing <- required_pkgs[!sapply(required_pkgs, requireNamespace, quietly = TRUE)]
if (length(missing) > 0) {
  stop("Missing required packages: ", paste(missing, collapse = ", "),
       "\nInstall with: install.packages(c('", paste(missing, collapse = "', '"), "'))")
}

# Set environment variable that Quarto would set
Sys.setenv(QUARTO_PROJECT_DIR = getwd())

# Source and run the main render script
cat("Running quarto-rdocs...\n\n")
source("_extensions/quarto-rdocs/R/rdocs-render.R")

# Run main function
result <- main()

cat("\n=== Summary ===\n")
cat("Generated", nrow(result), "documentation pages\n")
cat("Output directory: reference/\n")
cat("\nFiles generated:\n")
cat(paste(" -", result$file, collapse = "\n"), "\n")

cat("\nNext steps:\n")
cat("1. Review generated files in reference/\n")
cat("2. Run 'quarto preview' to see the site\n")
cat("3. Run 'quarto render' to build the final site\n")
