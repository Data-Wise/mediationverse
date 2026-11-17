#' Update mediationverse Packages
#'
#' @description
#' Updates all mediationverse packages to their latest versions from GitHub
#' or CRAN.
#'
#' @param packages Character vector of package names to update. Default is
#'   all core packages.
#' @param ... Additional arguments passed to the installation function.
#' @param only_outdated Logical. If `TRUE`, update only members whose installed
#'   version is older than the newest on their recommended source, plus members
#'   that are not installed. A member whose newest version cannot be determined
#'   (for example offline) is kept. This makes network requests to look up the
#'   newest versions. Default `FALSE`.
#' @param dry_run Logical. If `TRUE`, print what would be installed and return
#'   it without installing anything. Default `FALSE`.
#'
#' @details
#' This function uses `pak::pak()` if available (recommended), otherwise

#' falls back to `remotes::install_github()` for GitHub packages and
#' `utils::install.packages()` for CRAN packages.
#'
#' Package sources:
#' - **mediationverse**: GitHub (data-wise/mediationverse)
#' - **medfit**: GitHub (data-wise/medfit) — CRAN has 0.3.2, which predates two
#'   result-changing fixes in 0.5.0 (serial `te()`/`pm()` and `confint(parm = "paths")`)
#' - **probmed**: GitHub (data-wise/probmed)
#' - **RMediation**: CRAN
#' - **medrobust**: GitHub (data-wise/medrobust)
#' - **medsim**: GitHub (data-wise/medsim)
#' - **missingmed**: GitHub (data-wise/missingmed)
#'
#' @return Invisibly returns a character vector of updated package names (with
#'   `dry_run = TRUE`, the names that would be updated).
#'
#' @examples
#' \dontrun{
#' # Update all packages
#' mediationverse_update()
#'
#' # Update specific packages
#' mediationverse_update(c("medfit", "probmed"))
#'
#' # Only what is outdated, and preview first
#' mediationverse_update(only_outdated = TRUE, dry_run = TRUE)
#' }
#'
#' @export
mediationverse_update <- function(packages = NULL, ..., only_outdated = FALSE,
                                  dry_run = FALSE) {
  for (arg in c("only_outdated", "dry_run")) {
    val <- get(arg)
    if (!is.logical(val) || length(val) != 1L || is.na(val)) {
      stop(sprintf("`%s` must be TRUE or FALSE.", arg), call. = FALSE)
    }
  }

  # Package sources come from the internal registry (repos lowercased, as
  # this function has always passed them to pak/remotes).
  github_pkgs <- tolower(mv_repos()[mv_github_packages()])

  cran_pkgs <- mv_cran_packages()

  # Default to all packages
  if (is.null(packages)) {
    packages <- c(names(github_pkgs), cran_pkgs)
  }

  # Validate package names
  all_pkgs <- c(names(github_pkgs), cran_pkgs)
  invalid <- setdiff(packages, all_pkgs)
  if (length(invalid) > 0) {
    stop(
      "Unknown packages: ", paste(invalid, collapse = ", "), "\n",
      "Valid packages are: ", paste(all_pkgs, collapse = ", "),
      call. = FALSE
    )
  }

  # Keep only members that need an update: outdated ones, and ones not
  # installed. An unknown latest version keeps the member (install is the
  # safe default).
  if (only_outdated) {
    packages <- Filter(function(pkg) {
      if (!identical(pkg_state(pkg), "ok")) {
        return(TRUE)
      }
      !isFALSE(is_outdated(pkg_version(pkg), pkg_latest(pkg, mv_source(pkg))))
    }, packages)
    if (length(packages) == 0L) {
      msg <- "All requested members are up to date."
      if (requireNamespace("cli", quietly = TRUE)) cli::cli_alert_success(msg) else message(msg)
      return(invisible(character(0)))
    }
  }

  if (dry_run) {
    lines <- vapply(packages, function(pkg) {
      sprintf("%s (from %s)", pkg, mv_source(pkg))
    }, character(1))
    message("Dry run: nothing installed. Would update:")
    for (line in lines) message("  ", line)
    return(invisible(packages))
  }

  # Check for pak
  use_pak <- requireNamespace("pak", quietly = TRUE)

  if (use_pak) {
    # Use pak (preferred)
    if (requireNamespace("cli", quietly = TRUE)) {
      cli::cli_alert_info("Updating packages using {.pkg pak}...")
    } else {
      message("Updating packages using pak...")
    }

    # Build package specs
    specs <- character(0)
    for (pkg in packages) {
      if (pkg %in% names(github_pkgs)) {
        specs <- c(specs, github_pkgs[pkg])
      } else {
        specs <- c(specs, pkg)
      }
    }

    pak::pak(specs, ...)
  } else {
    # Fall back to remotes/install.packages
    if (requireNamespace("cli", quietly = TRUE)) {
      cli::cli_alert_warning(
        "Package {.pkg pak} not found. Using {.pkg remotes} instead."
      )
      cli::cli_text("Install pak for faster updates: {.code install.packages('pak')}")
    } else {
      message("Package 'pak' not found. Using remotes instead.")
      message("Install pak for faster updates: install.packages('pak')")
    }

    # GitHub packages
    github_to_update <- intersect(packages, names(github_pkgs))
    if (length(github_to_update) > 0) {
      if (!requireNamespace("remotes", quietly = TRUE)) {
        stop("Package 'remotes' required. Install with: install.packages('remotes')",
          call. = FALSE
        )
      }
      for (pkg in github_to_update) {
        remotes::install_github(github_pkgs[pkg], ...)
      }
    }

    # CRAN packages
    cran_to_update <- intersect(packages, cran_pkgs)
    if (length(cran_to_update) > 0) {
      utils::install.packages(cran_to_update, ...)
    }
  }

  if (requireNamespace("cli", quietly = TRUE)) {
    cli::cli_alert_success("Updated {length(packages)} package{?s}")
  } else {
    message(sprintf("Updated %d package(s)", length(packages)))
  }

  invisible(packages)
}
