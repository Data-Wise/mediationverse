#' Attach All mediationverse Packages
#'
#' @description
#' `library(mediationverse)` attaches only medfit (selective loading). This
#' attaches every installed core member in one call, which suits teaching and
#' scripts that use the whole ecosystem.
#'
#' @return Invisibly, a named character vector with one status per core
#'   package: `"attached"`, `"already attached"`, `"not installed"` or
#'   `"failed to load"`. A package that cannot be attached never aborts the
#'   call.
#'
#' @details
#' Attaching several packages can mask functions. Run
#' [mediationverse_conflicts()] afterwards to see which.
#'
#' @examples
#' \dontrun{
#' mediationverse_attach_all()
#' }
#'
#' @export
mediationverse_attach_all <- function() {
  pkgs <- mv_core_packages()
  status <- stats::setNames(character(length(pkgs)), pkgs)

  for (pkg in pkgs) {
    status[[pkg]] <- if (is_attached(pkg)) {
      "already attached"
    } else {
      state <- pkg_state(pkg)
      if (identical(state, "absent")) {
        "not installed"
      } else if (identical(state, "broken")) {
        "failed to load"
      } else {
        tryCatch(
          {
            pkg_attach(pkg)
            "attached"
          },
          error = function(e) "failed to load"
        )
      }
    }
  }

  newly <- names(status)[status == "attached"]
  already <- names(status)[status == "already attached"]
  absent <- names(status)[status == "not installed"]
  failed <- names(status)[status == "failed to load"]

  if (length(newly) > 0) cli::cli_alert_success("Attached {.pkg {newly}}")
  if (length(already) > 0) cli::cli_alert_info("Already attached: {.pkg {already}}")
  if (length(absent) > 0) cli::cli_alert_warning("Not installed: {.pkg {absent}}")
  if (length(failed) > 0) cli::cli_alert_warning("Failed to load: {.pkg {failed}}")
  if (length(newly) + length(already) >= 2) {
    cli::cli_alert_info("Check for masked functions with {.code mediationverse_conflicts()}.")
  }

  invisible(status)
}

# Attach one package. Isolated so tests can mock it. The package name is a
# variable on purpose: a literal library() call trips R CMD check in a
# meta-package.
#' @noRd
pkg_attach <- function(pkg) {
  suppressPackageStartupMessages(
    library(pkg, character.only = TRUE, warn.conflicts = FALSE)
  )
  invisible()
}
