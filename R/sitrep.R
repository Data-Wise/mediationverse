#' Situation Report for the mediationverse Ecosystem
#'
#' @description
#' Prints a summary of the installed mediationverse packages, their versions,
#' and installation sources. Inspired by `tidyverse::tidyverse_sitrep()`.
#'
#' @param checks Logical. If `TRUE`, also run environment checks and print
#'   them after the report: installed members against the minimum versions the
#'   ecosystem expects (failing below it, and warning when a compatible version
#'   predates the recommended one, e.g. medfit before 0.5.0), optional
#'   dependencies (OpenMx, needed for `RMediation::mbco()`), and function
#'   conflicts among installed members.
#'   Default `FALSE` leaves the report unchanged apart from a one-line hint.
#'
#' @return Invisibly returns a data frame with columns `package`, `installed`,
#'   `version` and `source`. `source` is the *recommended* install source
#'   (`"CRAN"` or `"GitHub"`) from the ecosystem registry; it is not detected
#'   from the installed copy, so a package installed from elsewhere (for
#'   example a CRAN `medfit` that predates the GitHub fixes) still shows its
#'   recommended source. With `checks = TRUE` the checks are attached as the
#'   `"checks"` attribute: a data frame with columns `check`, `status`
#'   (`"pass"`, `"warn"` or `"fail"`), `message` and `fix`. Called mainly for
#'   its side effect of printing the situation report.
#'
#' @examples
#' mediationverse_sitrep()
#' mediationverse_sitrep(checks = TRUE)
#'
#' @export
mediationverse_sitrep <- function(checks = FALSE) {
  # Members, install sources and repositories come from the internal registry.
  core <- mv_core_packages()
  github_repos <- mv_repos()

  use_cli <- requireNamespace("cli", quietly = TRUE)

  if (use_cli) {
    cli::cli_h1("mediationverse situation report")
    cli::cli_text(
      "{.strong R} {getRversion()} | {.strong Platform} {R.version$platform}"
    )
    cli::cli_text(
      "{.strong mediationverse} {utils::packageVersion('mediationverse')}"
    )
    cli::cli_rule()
    cli::cli_h2("Core packages")
  } else {
    cat("mediationverse situation report\n")
    cat(strrep("-", 50), "\n")
    cat(sprintf("R %s | Platform: %s\n", getRversion(), R.version$platform))
    cat(sprintf("mediationverse %s\n", utils::packageVersion("mediationverse")))
    cat(strrep("-", 50), "\n")
    cat("Core packages:\n")
  }

  pkg_data <- lapply(core, function(pkg) {
    inst <- requireNamespace(pkg, quietly = TRUE)
    ver <- if (inst) as.character(utils::packageVersion(pkg)) else NA_character_
    source <- mv_source(pkg)
    list(package = pkg, installed = inst, version = ver, source = source)
  })

  for (pd in pkg_data) {
    if (use_cli) {
      src_label <- if (pd$source == "CRAN") {
        cli::col_blue("CRAN")
      } else {
        cli::col_cyan("GitHub")
      }

      if (pd$installed) {
        tick <- cli::col_green(cli::symbol$tick)
        cli::cli_text(
          "  {tick} {.pkg {pd$package}} {.field {pd$version}} [recommended: {src_label}]"
        )
      } else {
        cross <- cli::col_red(cli::symbol$cross)
        cli::cli_text(
          "  {cross} {.pkg {pd$package}} {.emph (not installed)} [recommended: {src_label}]"
        )
        repo <- github_repos[pd$package]
        if (!is.na(repo)) {
          cli::cli_text(
            "    Install: {.code pak::pak(\"{repo}\")}"
          )
        }
      }
    } else {
      status <- if (pd$installed) "[x]" else "[ ]"
      ver_str <- if (pd$installed) pd$version else "not installed"
      cat(sprintf("  %s %s %s [recommended: %s]\n", status, pd$package, ver_str, pd$source))
    }
  }

  if (use_cli) {
    cli::cli_rule()
    cli::cli_h2("CRAN status")
    cli::cli_bullets(c(
      "*" = "{.pkg RMediation} {.field 1.6.1} - {.url https://cran.r-project.org/package=RMediation}",
      "i" = "{.pkg medfit} - install from GitHub; CRAN has {.field 0.3.2}, which predates two result-changing fixes in {.field 0.5.0}",
      "i" = "{.pkg probmed}, {.pkg medrobust}, {.pkg medsim}, {.pkg missingmed} - GitHub only (pre-CRAN)"
    ))
  } else {
    cat(strrep("-", 50), "\n")
    cat("CRAN status:\n")
    cat("  [CRAN] RMediation 1.6.1\n")
    cat("  [GitHub] medfit (CRAN has 0.3.2, which predates two result-changing fixes in 0.5.0)\n")
    cat("  [GitHub only] probmed, medrobust, medsim, missingmed\n")
  }

  checks_df <- NULL
  if (isTRUE(checks)) {
    checks_df <- mv_checks()
    if (use_cli) print_checks(checks_df) else print_checks_plain(checks_df)
  } else if (use_cli) {
    cli::cli_text(
      "Run {.code mediationverse_sitrep(checks = TRUE)} for dependency checks."
    )
  } else {
    cat("Run mediationverse_sitrep(checks = TRUE) for dependency checks.\n")
  }

  out <- as.data.frame(
    do.call(rbind, lapply(pkg_data, function(pd) {
      data.frame(
        package   = pd$package,
        installed = pd$installed,
        version   = if (is.na(pd$version)) NA_character_ else pd$version,
        source    = pd$source,
        stringsAsFactors = FALSE
      )
    })),
    stringsAsFactors = FALSE
  )

  if (!is.null(checks_df)) {
    attr(out, "checks") <- checks_df
  }

  invisible(out)
}
