#' Attach Core Packages from mediationverse
#'
#' @description
#' This function is called when the mediationverse package is attached.
#' Following the selective loading strategy (Option 2), only medfit is
#' loaded by default. Other packages should be loaded explicitly.
#'
#' @keywords internal
#' @noRd
mediationverse_attach <- function() {
  # Only load medfit (foundation package) by default
  # Other packages: probmed, RMediation, medrobust, medsim
  # should be loaded explicitly with library()
  foundation <- "medfit"

  # Check if medfit needs to be loaded
  if (!is_attached(foundation)) {
    # Suppress startup messages from medfit
    suppressPackageStartupMessages(
      library(foundation, character.only = TRUE, warn.conflicts = FALSE)
    )
  }

  invisible()
}

#' Check if packages are attached
#'
#' @param x Character vector of package names
#' @return Logical vector indicating which packages are attached
#' @keywords internal
#' @noRd
is_attached <- function(x) {
  paste0("package:", x) %in% search()
}

#' Get package versions
#'
#' @param x Character vector of package names
#' @return Character vector of versions
#' @keywords internal
#' @noRd
package_version_string <- function(x) {
  vapply(x, function(pkg) {
    if (!requireNamespace(pkg, quietly = TRUE)) {
      return("(not installed)")
    }
    as.character(utils::packageVersion(pkg))
  }, character(1))
}
