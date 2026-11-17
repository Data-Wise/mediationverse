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

# Is the package present on disk (installed), whether or not it can load?
# Isolated so tests can mock it.
#' @noRd
pkg_on_disk <- function(pkg) {
  nzchar(system.file(package = pkg))
}

# State of one package: "ok" (loadable), "broken" (installed but its namespace
# fails to load, e.g. a broken dependency) or "absent" (not installed).
# pkg_installed() alone cannot tell the last two apart.
#' @noRd
pkg_state <- function(pkg) {
  if (pkg_installed(pkg)) {
    "ok"
  } else if (pkg_on_disk(pkg)) {
    "broken"
  } else {
    "absent"
  }
}

# Core members that are installed but cannot be loaded.
#' @noRd
broken_members <- function() {
  pkgs <- mv_core_packages()
  pkgs[vapply(pkgs, function(p) identical(pkg_state(p), "broken"), logical(1))]
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

    state <- pkg_state(pkg)

    # Reported by the "load" check; do not double-report it as "not installed".
    if (identical(state, "broken")) {
      return(NULL)
    }

    if (identical(state, "absent")) {
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

    if (package_version(ver) < package_version(min_ver)) {
      check_row(
        check, "fail",
        sprintf("%s %s is older than the required %s", pkg, ver, min_ver),
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

# Installed members must be loadable: an installed package whose namespace
# fails to load (for example a broken dependency) is unusable, and the other
# checks cannot inspect it.
#' @noRd
check_loadable <- function() {
  broken <- broken_members()

  if (length(broken) == 0) {
    return(check_row("load", "pass", "All installed members can be loaded"))
  }

  check_row(
    "load", "fail",
    sprintf(
      "%s installed but cannot be loaded",
      paste0(paste(broken, collapse = ", "), if (length(broken) == 1) " is" else " are")
    ),
    sprintf("Reinstall %s and its dependencies", paste(broken, collapse = ", "))
  )
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

  reg <- mv_registry()
  rmed_min <- reg$min_version[reg$package == "RMediation"]
  rmed_ver <- pkg_version("RMediation")
  if (is.na(rmed_ver)) {
    return(check_row(
      "optional:OpenMx", "warn",
      "RMediation's version could not be read, so mbco() availability cannot be confirmed",
      "install.packages(\"RMediation\")"
    ))
  }
  if (package_version(rmed_ver) < package_version(rmed_min)) {
    return(check_row(
      "optional:OpenMx", "warn",
      sprintf(
        "RMediation %s is older than the required %s, so mbco() availability cannot be confirmed",
        rmed_ver, rmed_min
      ),
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
  members <- mv_core_packages()
  states <- vapply(members, pkg_state, character(1))
  installed <- members[states == "ok"]
  # Installed but unloadable members cannot be inspected either.
  broken <- members[states == "broken"]

  conflicts <- find_conflicts(installed)
  n <- nrow(conflicts)
  failed <- union(attr(conflicts, "failed_lookup"), broken)

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
        "%s; %s could not be inspected (exports unreadable or package fails to load), so the check is incomplete",
        found, paste(failed, collapse = ", ")
      ),
      "Reinstall the package(s) that could not be inspected"
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

# Members installed from somewhere other than their recommended source. A
# warning, not a failure: the version check already fails on a bad version, and
# a differing source (say, RMediation from GitHub instead of CRAN) can be
# deliberate.
#' @noRd
check_sources <- function() {
  reg <- mv_registry()
  reg <- reg[reg$core, , drop = FALSE]

  off <- character(0)
  for (i in seq_len(nrow(reg))) {
    pkg <- reg$package[i]
    if (!identical(pkg_state(pkg), "ok")) next
    from <- pkg_provenance(pkg)
    if (!is.na(from) && !source_matches(from, reg$source[i])) {
      off <- c(off, sprintf("%s (%s, recommended %s)", pkg, from, reg$source[i]))
    }
  }

  if (length(off) == 0) {
    return(check_row("source", "pass", "Installed members come from their recommended source"))
  }

  check_row(
    "source", "warn",
    sprintf("Installed from a different source than recommended: %s", paste(off, collapse = "; ")),
    "Reinstall with pak::pak() from the recommended source if this was not intended"
  )
}

# Installed members that are older than the newest version on their recommended
# source. A warning, never a failure: an old version is not a broken one (the
# minimum-version check owns failures). Makes network requests, so it only runs
# with updates = TRUE.
#' @noRd
check_updates <- function() {
  reg <- mv_registry()
  reg <- reg[reg$core, , drop = FALSE]

  old <- character(0)
  checked <- 0L
  for (i in seq_len(nrow(reg))) {
    pkg <- reg$package[i]
    if (!identical(pkg_state(pkg), "ok")) next
    ver <- pkg_version(pkg)
    latest <- pkg_latest(pkg, reg$source[i])
    outdated <- is_outdated(ver, latest)
    if (is.na(outdated)) next
    checked <- checked + 1L
    if (outdated) old <- c(old, sprintf("%s %s -> %s", pkg, ver, latest))
  }

  if (length(old) > 0) {
    return(check_row(
      "updates", "warn",
      sprintf("Newer versions available: %s", paste(old, collapse = ", ")),
      "Run mediationverse_update()"
    ))
  }
  if (checked == 0L) {
    return(check_row(
      "updates", "warn", "Could not check for updates (offline or no installed members)",
      "Retry with a network connection"
    ))
  }
  check_row("updates", "pass", "Installed members are up to date")
}

# Run every check and bind the rows. The updates check needs the network, so it
# is opt-in.
#' @noRd
mv_checks <- function(updates = FALSE) {
  out <- rbind(
    check_loadable(),
    check_min_versions(),
    check_sources(),
    if (updates) check_updates(),
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
