# Package startup and attachment

.onAttach <- function(libname, pkgname) {
  # Get version information
  med_version <- utils::packageVersion("mediationverse")
  core_packages <- c("medfit", "probmed", "RMediation", "medrobust")

  # Try to attach core packages
  tryCatch(
    mediationverse_attach(),
    error = function(e) {
      packageStartupMessage(
        "Some mediationverse packages could not be loaded.\n",
        "Please ensure all packages are installed:\n",
        "  install.packages(c('medfit', 'probmed', 'RMediation', 'medrobust'))"
      )
    }
  )

  # Get versions of loaded packages
  versions <- package_version_string(core_packages)

  # Create startup message using cli if available
  if (requireNamespace("cli", quietly = TRUE)) {
    msg <- paste0(
      cli::rule(
        left = "Attaching packages",
        right = paste0("mediationverse ", med_version)
      ),
      "\n",
      cli::symbol$tick, " medfit     ", versions["medfit"],
      "     ", cli::symbol$tick, " probmed    ", versions["probmed"], "\n",
      cli::symbol$tick, " RMediation ", versions["RMediation"],
      "     ", cli::symbol$tick, " medrobust  ", versions["medrobust"], "\n",
      cli::rule()
    )
  } else {
    # Fallback message if cli is not available
    msg <- paste0(
      "-- Attaching packages ---------------- mediationverse ", med_version, " --\n",
      "+ medfit     ", versions["medfit"], "     + probmed    ", versions["probmed"], "\n",
      "+ RMediation ", versions["RMediation"], "     + medrobust  ", versions["medrobust"], "\n",
      "---------------------------------------------------------------"
    )
  }

  packageStartupMessage(msg)
}
