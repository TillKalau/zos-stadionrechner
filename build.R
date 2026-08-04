# ZOS-Stadionrechner für Shinylive bauen
# Einmalig erforderlich:
# install.packages("shinylive")
library(S7)

if (!requireNamespace("shinylive", quietly = TRUE)) {
  stop("Das Paket 'shinylive' fehlt. Bitte zuerst install.packages('shinylive') ausführen.")
}

project_dir <- normalizePath(getwd(), winslash = "/", mustWork = TRUE)
src_dir     <- file.path(project_dir, "src")
site_dir    <- file.path(project_dir, "site")
app_dir     <- file.path(site_dir, "app")

if (!file.exists(file.path(src_dir, "app.R"))) {
  stop("src/app.R wurde nicht gefunden. Bitte build.R im Projektordner ausführen.")
}

if (dir.exists(app_dir)) {
  unlink(app_dir, recursive = TRUE, force = TRUE)
}

dir.create(site_dir, recursive = TRUE, showWarnings = FALSE)

shinylive::export(
  appdir  = src_dir,
  destdir = app_dir
)

cat("\nBuild fertig. Für GitHub/Cloudflare den Inhalt des Ordners 'site' verwenden.\n")
