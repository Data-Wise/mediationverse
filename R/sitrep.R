#' Situation Report for the mediationverse Ecosystem
#'
#' @description
#' Prints a summary of the installed mediationverse packages, their versions,
#' and installation sources. Inspired by `tidyverse::tidyverse_sitrep()`.
#'
#' @return Invisibly returns a data frame with package status. Called for its
#'   side effect of printing the situation report.
#'
#' @examples
#' mediationverse_sitrep()
#'
#' @export
mediationverse_sitrep <- function() {
  # Known package sources (CRAN vs GitHub-only)
  cran_pkgs <- c("RMediation")
  github_only <- c("medfit", "probmed", "medrobust", "medsim", "mediationverse")

  core <- c("medfit", "probmed", "RMediation", "medrobust", "medsim")
  github_repos <- c(
    mediationverse = "Data-Wise/mediationverse",
    medfit         = "Data-Wise/medfit",
    probmed        = "Data-Wise/probmed",
    RMediation     = "Data-Wise/rmediation",
    medrobust      = "Data-Wise/medrobust",
    medsim         = "Data-Wise/medsim"
  )

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
    source <- if (pkg %in% cran_pkgs) "CRAN" else "GitHub"
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
          "  {tick} {.pkg {pd$package}} {.field {pd$version}} [{src_label}]"
        )
      } else {
        cross <- cli::col_red(cli::symbol$cross)
        cli::cli_text(
          "  {cross} {.pkg {pd$package}} {.emph (not installed)} [{src_label}]"
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
      cat(sprintf("  %s %s %s [%s]\n", status, pd$package, ver_str, pd$source))
    }
  }

  if (use_cli) {
    cli::cli_rule()
    cli::cli_h2("CRAN status")
    cli::cli_bullets(c(
      "*" = "{.pkg RMediation} {.field 1.5.0} - {.url https://cran.r-project.org/package=RMediation}",
      "i" = "{.pkg medfit} - install {.field 0.3.x} from GitHub; CRAN has {.field 0.2.1}, but the ecosystem needs >= 0.3.0",
      "i" = "{.pkg probmed}, {.pkg medrobust}, {.pkg medsim} - GitHub only (pre-CRAN)"
    ))
  } else {
    cat(strrep("-", 50), "\n")
    cat("CRAN status:\n")
    cat("  [CRAN] RMediation 1.5.0\n")
    cat("  [GitHub] medfit 0.3.x (CRAN has 0.2.1; ecosystem needs >= 0.3.0)\n")
    cat("  [GitHub only] probmed, medrobust, medsim\n")
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

  invisible(out)
}
