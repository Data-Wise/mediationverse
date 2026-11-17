#' Situation Report for the mediationverse Ecosystem
#'
#' @description
#' Prints a summary of the installed mediationverse packages, their versions,
#' and installation sources. Inspired by `tidyverse::tidyverse_sitrep()`.
#'
#' @param checks Logical. If `TRUE`, also run environment checks and print
#'   them after the report: installed members against the minimum versions the
#'   ecosystem requires (failing below it, e.g. medfit before 0.5.0), optional
#'   dependencies (OpenMx, needed for `RMediation::mbco()`), and function
#'   conflicts among installed members.
#'   Default `FALSE` leaves the report unchanged apart from a one-line hint.
#'
#' @return Invisibly returns a data frame with columns `package`, `installed`,
#'   `version`, `source` and `installed_from`. `installed_from` is detected from
#'   the installed copy's `DESCRIPTION`: `"CRAN"`, `"GitHub"`, `"r-universe"`,
#'   `"base"`, `"local"` (source or `load_all()` installs), `"other"`, or `NA`
#'   (not installed or unreadable). `source` is the *recommended* install source
#'   (`"CRAN"` or `"GitHub"`) from the ecosystem registry; compare it with
#'   `installed_from` to see whether an install matches. With `checks = TRUE` the checks are attached as the
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
    # pkg_version() never errors: an unreadable version is NA, reported as
    # "unknown" below and flagged by the checks, instead of aborting the report.
    ver <- if (inst) pkg_version(pkg) else NA_character_
    source <- mv_source(pkg)
    # Where the installed copy actually came from (NA when not installed).
    from <- if (inst) pkg_provenance(pkg) else NA_character_
    list(package = pkg, installed = inst, version = ver, source = source,
         installed_from = from)
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
        ver_label <- if (is.na(pd$version)) "unknown" else pd$version
        from_label <- from_text(pd$installed_from)
        cli::cli_text(
          "  {tick} {.pkg {pd$package}} {.field {ver_label}} ({from_label}) [recommended: {src_label}]"
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
      ver_str <- if (!pd$installed) {
        "not installed"
      } else if (is.na(pd$version)) {
        "unknown"
      } else {
        pd$version
      }
      from_str <- if (pd$installed) sprintf(" (%s)", from_text(pd$installed_from)) else ""
      cat(sprintf("  %s %s %s%s [recommended: %s]\n", status, pd$package, ver_str, from_str, pd$source))
    }
  }

  # Install sources: only members installed from somewhere other than their
  # recommended source are listed, so the section never carries stale version
  # numbers or claims about what CRAN currently has.
  mismatched <- Filter(function(pd) {
    isTRUE(pd$installed) && !is.na(pd$installed_from) &&
      !source_matches(pd$installed_from, pd$source)
  }, pkg_data)

  if (use_cli) {
    cli::cli_rule()
    cli::cli_h2("Install sources")
    if (length(mismatched) == 0L) {
      cli::cli_text("Installed members come from their recommended source.")
    } else {
      bullets <- vapply(mismatched, function(pd) {
        sprintf("{.pkg %s} installed from %s; recommended: %s",
                pd$package, pd$installed_from, pd$source)
      }, character(1))
      names(bullets) <- rep("!", length(bullets))
      cli::cli_bullets(bullets)
    }
  } else {
    cat(strrep("-", 50), "\n")
    cat("Install sources:\n")
    if (length(mismatched) == 0L) {
      cat("  Installed members come from their recommended source.\n")
    } else {
      for (pd in mismatched) {
        cat(sprintf("  [!] %s installed from %s; recommended: %s\n",
                    pd$package, pd$installed_from, pd$source))
      }
    }
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
        installed_from = pd$installed_from,
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

# Short label for where an installed copy came from; "unknown origin" when the
# provenance could not be read.
#' @noRd
from_text <- function(from) {
  if (is.na(from)) "unknown origin" else paste("from", from)
}

# Whether an installed copy's provenance satisfies the recommended source.
# Recommended "GitHub" is satisfied by GitHub and r-universe (the same Data-Wise
# builds); a development install ("local") is never flagged. "CRAN" is
# satisfied only by CRAN.
#' @noRd
source_matches <- function(from, recommended) {
  if (from %in% c("local", "base")) {
    return(TRUE)
  }
  if (identical(recommended, "CRAN")) {
    identical(from, "CRAN")
  } else {
    from %in% c("GitHub", "r-universe")
  }
}
