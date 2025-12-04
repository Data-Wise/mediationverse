#' List mediationverse Packages
#'
#' @description
#' Lists all core packages in the mediationverse ecosystem along with their
#' installation status and versions.
#'
#' @param include_self Logical. Include mediationverse itself in the list?
#'   Default is TRUE.
#'
#' @return A data frame with columns:
#'   - `package`: Package name
#'   - `installed`: Logical, whether package is installed
#'   - `version`: Package version (NA if not installed
#'   - `attached`: Logical, whether package is currently attached
#'
#' @examples
#' mediationverse_packages()
#'
#' @export
mediationverse_packages <- function(include_self = TRUE) {
  core <- c("medfit", "probmed", "RMediation", "medrobust", "medsim")


if (include_self) {
    core <- c("mediationverse", core)
  }

  installed <- vapply(core, function(pkg) {
    requireNamespace(pkg, quietly = TRUE)
  }, logical(1))

  versions <- vapply(core, function(pkg) {
    if (requireNamespace(pkg, quietly = TRUE)) {
      as.character(utils::packageVersion(pkg))
    } else {
      NA_character_
    }
  }, character(1))

  attached <- vapply(core, function(pkg) {
    paste0("package:", pkg) %in% search()
  }, logical(1))

  df <- data.frame(
    package = core,
    installed = installed,
    version = versions,
    attached = attached,
    row.names = NULL,
    stringsAsFactors = FALSE
  )

  class(df) <- c("mediationverse_packages", "data.frame")
  df
}

#' @export
print.mediationverse_packages <- function(x, ...) {
  if (requireNamespace("cli", quietly = TRUE)) {
    cli::cli_h1("mediationverse packages")

    for (i in seq_len(nrow(x))) {
      pkg <- x$package[i]
      if (x$installed[i]) {
        status <- cli::col_green(cli::symbol$tick)
        ver <- x$version[i]
        if (x$attached[i]) {
          cli::cli_text("{status} {.pkg {pkg}} {.field {ver}} (attached)")
        } else {
          cli::cli_text("{status} {.pkg {pkg}} {.field {ver}}")
        }
      } else {
        status <- cli::col_red(cli::symbol$cross)
        cli::cli_text("{status} {.pkg {pkg}} {.emph (not installed)}")
      }
    }
  } else {
    # Fallback without cli
    cat("mediationverse packages\n")
    cat(strrep("-", 40), "\n")
    for (i in seq_len(nrow(x))) {
      pkg <- x$package[i]
      if (x$installed[i]) {
        status <- "[x]"
        ver <- x$version[i]
        attached <- if (x$attached[i]) " (attached)" else ""
        cat(sprintf("%s %s %s%s\n", status, pkg, ver, attached))
      } else {
        cat(sprintf("[ ] %s (not installed)\n", pkg))
      }
    }
  }

  invisible(x)
}
