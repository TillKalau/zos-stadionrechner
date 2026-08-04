# ZOS-Stadionrechner – Cloudflare/GitHub-Paket

## Inhalt

* `src/app.R` – deine Shiny-App
* `build.R` – erzeugt den Shinylive-Export
* `site/index.html` – vorgeschalteter Ladebildschirm
* `site/assets/` – Design, Ladeanimation und Favicon
* `site/app/` – wird beim Build automatisch erzeugt

## 1\. Einmalig in R installieren    

```r
install.packages("shinylive")
```

Die von der App benötigten Pakete sind:

```r
install.packages(c("shiny", "ggplot2", "scales"))
```

## 2\. Export erstellen

Öffne das Projekt in RStudio, setze den Projektordner als Arbeitsverzeichnis und führe aus:

```r
source("build.R")
```

Danach liegt die vollständige Website im Ordner `site`.

## 3\. Lokal testen

Nicht per Doppelklick öffnen, sondern über einen lokalen Webserver. Zum Beispiel in R:

```r
httpuv::runStaticServer("site", port = 8000)
```

Dann im Browser öffnen:

```text
http://127.0.0.1:8000
```

## 4\. GitHub und Cloudflare Pages

Am einfachsten lädst du den **Inhalt des Ordners `site`** in dein GitHub-Repository hoch. Dabei muss `index.html` direkt auf der obersten Ebene des Repositorys liegen.

Cloudflare Pages:

* Framework-Voreinstellung: `None`
* Build-Befehl: leer
* Build-Ausgabeverzeichnis: `/`

Bei Änderungen an `app.R` erneut `source("build.R")` ausführen und den aktualisierten `site/app`-Ordner zu GitHub hochladen.

