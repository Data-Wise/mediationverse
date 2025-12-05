# Package startup and attachment

.onAttach <- function(libname, pkgname) {
  # Get version information
  med_version <- utils::packageVersion("mediationverse")
  core_packages <- c("medfit", "probmed", "RMediation", "medrobust", "medsim")

  # Try to attach core packages
  tryCatch(
    mediationverse_attach(),
    error = function(e) {
      packageStartupMessage(
        "Some mediationverse packages could not be loaded.\n",
        "Please ensure all packages are installed:\n",
        "  pak::pak(c('Data-Wise/medfit', 'Data-Wise/probmed',\n",
        "             'RMediation', 'Data-Wise/medrobust', 'Data-Wise/medsim'))"
      )
    }
  )

  # Get versions of loaded packages
  versions <- package_version_string(core_packages)

  # Create startup message using cli if available
  if (requireNamespace("cli", quietly = TRUE)) {
    tick <- cli::symbol$tick
    msg <- paste0(
      cli::rule(
        left = "Attaching packages",
        right = paste0("mediationverse ", med_version)
      ),
      "\n",
      tick, " medfit     ", versions["medfit"],
      "   ", tick, " probmed    ", versions["probmed"], "\n",
      tick, " RMediation ", versions["RMediation"],
      "   ", tick, " medrobust  ", versions["medrobust"], "\n",
      tick, " medsim     ", versions["medsim"], "\n",
      cli::rule()
    )
  } else {
    # Fallback message if cli is not available
    msg <- paste0(
      "-- Attaching packages ----------- mediationverse ", med_version, " --\n",
      "+ medfit     ", versions["medfit"],
      "   + probmed    ", versions["probmed"], "\n",
      "+ RMediation ", versions["RMediation"],
      "   + medrobust  ", versions["medrobust"], "\n",
      "+ medsim     ", versions["medsim"], "\n",
      "-------------------------------------------------------------"
    )
  }

  packageStartupMessage(msg)
}
