#' Update mediationverse Packages
#'
#' @description
#' Updates all mediationverse packages to their latest versions from GitHub
#' or CRAN.
#'
#' @param packages Character vector of package names to update. Default is
#'   all core packages.
#' @param ... Additional arguments passed to the installation function.
#'
#' @details
#' This function uses `pak::pak()` if available (recommended), otherwise

#' falls back to `remotes::install_github()` for GitHub packages and
#' `utils::install.packages()` for CRAN packages.
#'
#' Package sources:
#' - **mediationverse**: GitHub (data-wise/mediationverse)
#' - **medfit**: GitHub (data-wise/medfit)
#' - **probmed**: GitHub (data-wise/probmed)
#' - **RMediation**: CRAN
#' - **medrobust**: GitHub (data-wise/medrobust)
#' - **medsim**: GitHub (data-wise/medsim)
#'
#' @return Invisibly returns a character vector of updated package names.
#'
#' @examples
#' \dontrun{
#' # Update all packages
#' mediationverse_update()
#'
#' # Update specific packages
#' mediationverse_update(c("medfit", "probmed"))
#' }
#'
#' @export
mediationverse_update <- function(packages = NULL, ...) {
  # Package sources
  github_pkgs <- c(
    mediationverse = "data-wise/mediationverse",
    medfit = "data-wise/medfit",
    probmed = "data-wise/probmed",
    medrobust = "data-wise/medrobust",
    medsim = "data-wise/medsim"
  )

  cran_pkgs <- c("RMediation")

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
