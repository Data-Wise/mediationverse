# Environment checks behind mediationverse_sitrep(checks = TRUE).
#
# Each check yields one row: `check` (short id), `status` ("pass", "warn" or
# "fail"), `message` (what was found) and `fix` (what to do, "" when nothing).
# Everything here is read-only and offline.

# Installed version of a package as a string, or NA when it cannot be read.
# Isolated so tests can mock it.
#' @noRd
pkg_version <- function(pkg) {
  tryCatch(
    as.character(utils::packageVersion(pkg)),
    error = function(e) NA_character_
  )
}

#' @noRd
check_row <- function(check, status, message, fix = "") {
  data.frame(
    check = check,
    status = status,
    message = message,
    fix = fix,
    stringsAsFactors = FALSE
  )
}

# Installed members must meet the minimum version the ecosystem expects.
#' @noRd
check_min_versions <- function() {
  reg <- mv_registry()
  reg <- reg[reg$core & !is.na(reg$min_version), , drop = FALSE]

  rows <- lapply(seq_len(nrow(reg)), function(i) {
    pkg <- reg$package[i]
    min_ver <- reg$min_version[i]
    check <- paste0("version:", pkg)

    if (!pkg_installed(pkg)) {
      return(check_row(
        check, "warn",
        sprintf("%s is not installed (needs >= %s)", pkg, min_ver),
        sprintf("pak::pak(\"%s\")", reg$repo[i])
      ))
    }

    ver <- pkg_version(pkg)
    if (is.na(ver)) {
      return(check_row(
        check, "warn",
        sprintf("%s version could not be read", pkg)
      ))
    }

    rec_ver <- reg$recommended_version[i]

    if (package_version(ver) < package_version(min_ver)) {
      check_row(
        check, "fail",
        sprintf("%s %s is older than the required %s", pkg, ver, min_ver),
        sprintf("pak::pak(\"%s\")", reg$repo[i])
      )
    } else if (!is.na(rec_ver) && package_version(ver) < package_version(rec_ver)) {
      check_row(
        check, "warn",
        sprintf(
          "%s %s meets the minimum %s but predates %s, which has result-changing fixes",
          pkg, ver, min_ver, rec_ver
        ),
        sprintf("pak::pak(\"%s\")", reg$repo[i])
      )
    } else {
      check_row(
        check, "pass",
        sprintf("%s %s meets the minimum %s", pkg, ver, min_ver)
      )
    }
  })

  do.call(rbind, rows)
}

# Does an installed package export a given name? Isolated so tests can mock it.
#' @noRd
pkg_has_export <- function(pkg, name) {
  tryCatch(
    name %in% getNamespaceExports(pkg),
    error = function(e) FALSE
  )
}

# Optional dependencies that gate a feature of a member package. The OpenMx
# row only reports the feature as available when RMediation is installed and
# actually exports mbco().
#' @noRd
check_optional_deps <- function() {
  dep <- mv_optional_deps()
  openmx_min <- dep$min_version[dep$package == "OpenMx"]

  if (!pkg_installed("OpenMx")) {
    return(check_row(
      "optional:OpenMx", "warn",
      "OpenMx is not installed; RMediation::mbco() will not work",
      "install.packages(\"OpenMx\")"
    ))
  }

  openmx_ver <- pkg_version("OpenMx")
  if (is.na(openmx_ver)) {
    return(check_row(
      "optional:OpenMx", "warn",
      sprintf(
        "OpenMx is installed but its version could not be read, so it cannot be confirmed as >= %s",
        openmx_min
      ),
      "install.packages(\"OpenMx\")"
    ))
  }

  if (package_version(openmx_ver) < package_version(openmx_min)) {
    return(check_row(
      "optional:OpenMx", "warn",
      sprintf(
        "OpenMx %s is older than the %s RMediation requires; mbco() may not work",
        openmx_ver, openmx_min
      ),
      "install.packages(\"OpenMx\")"
    ))
  }

  if (!pkg_installed("RMediation")) {
    return(check_row(
      "optional:OpenMx", "warn",
      "OpenMx is installed, but RMediation is not, so mbco() is unavailable",
      "install.packages(\"RMediation\")"
    ))
  }

  if (!pkg_has_export("RMediation", "mbco")) {
    return(check_row(
      "optional:OpenMx", "warn",
      "OpenMx is installed, but the installed RMediation does not export mbco()",
      "install.packages(\"RMediation\")"
    ))
  }

  check_row(
    "optional:OpenMx", "pass",
    "OpenMx is installed (RMediation::mbco() available)"
  )
}

# Functions exported by more than one installed member.
#' @noRd
check_conflicts <- function() {
  installed <- mv_core_packages()
  installed <- installed[vapply(installed, pkg_installed, logical(1))]

  conflicts <- find_conflicts(installed)
  n <- nrow(conflicts)
  failed <- attr(conflicts, "failed_lookup")

  found <- if (n == 0) {
    "No export conflicts among inspected members"
  } else {
    sprintf(
      "%d function%s exported by more than one member: %s",
      n, if (n == 1) "" else "s",
      paste(conflicts$function_name, collapse = ", ")
    )
  }

  if (length(failed) > 0) {
    return(check_row(
      "conflicts", "warn",
      sprintf(
        "%s; exports of %s could not be read, so the check is incomplete",
        found, paste(failed, collapse = ", ")
      ),
      "Reinstall the package(s) whose exports could not be read"
    ))
  }

  if (n == 0) {
    check_row("conflicts", "pass", "No export conflicts among installed members")
  } else {
    check_row(
      "conflicts", "warn", found,
      "Call the version you want with package::function()"
    )
  }
}

# Run every check and bind the rows.
#' @noRd
mv_checks <- function() {
  out <- rbind(
    check_min_versions(),
    check_optional_deps(),
    check_conflicts()
  )
  rownames(out) <- NULL
  out
}

# Print a checks data frame as a short report.
#' @noRd
print_checks <- function(checks) {
  cli::cli_rule()
  cli::cli_h2("Checks")

  for (i in seq_len(nrow(checks))) {
    status <- checks$status[i]
    marker <- switch(status,
      pass = cli::col_green(cli::symbol$tick),
      warn = cli::col_yellow("!"),
      cli::col_red(cli::symbol$cross)
    )
    cli::cli_text("  {marker} {checks$message[i]}")
    if (nzchar(checks$fix[i])) {
      cli::cli_text("    Fix: {checks$fix[i]}")
    }
  }

  invisible(checks)
}

# Plain-text variant of print_checks() for the no-cli path.
#' @noRd
print_checks_plain <- function(checks) {
  cat(strrep("-", 50), "\n")
  cat("Checks:\n")
  for (i in seq_len(nrow(checks))) {
    marker <- switch(checks$status[i], pass = "[ok]", warn = "[!]", "[x]")
    cat(sprintf("  %s %s\n", marker, checks$message[i]))
    if (nzchar(checks$fix[i])) {
      cat(sprintf("      Fix: %s\n", checks$fix[i]))
    }
  }
  invisible(checks)
}
