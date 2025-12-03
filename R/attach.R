#' Attach Core Packages from mediationverse
#'
#' @description
#' This function is called when the mediationverse package is attached.
#' It loads the core packages in the ecosystem.
#'
#' @keywords internal
#' @noRd
mediationverse_attach <- function() {
  # Core packages in the mediationverse
  core <- c("medfit", "probmed", "RMediation", "medrobust")

  # Determine which packages need to be loaded
  to_load <- core[!is_attached(core)]

  if (length(to_load) == 0) {
    return(invisible())
  }

  # Suppress startup messages from individual packages
  suppressPackageStartupMessages(
    lapply(to_load, library, character.only = TRUE, warn.conflicts = FALSE)
  )

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
