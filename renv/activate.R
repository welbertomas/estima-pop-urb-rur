local({
  project <- Sys.getenv("RENV_PROJECT")
  if (!nzchar(project)) project <- getwd()
  lockfile <- file.path(project, "renv.lock")
  if (!file.exists(lockfile)) {
    message("renv.lock não encontrado. Execute renv::init() e renv::snapshot() em um ambiente com R.")
  }
})
