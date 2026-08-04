library(shiny)
library(ggplot2)
library(scales)

# ggplot2 4.x benötigt S7 im WebAssembly-Export.
# Die unerreichbare Zeile sorgt dafür, dass Shinylive das Paket mit exportiert.
if (FALSE) {
  library(S7)
}

# ------------------------------------------------------------
# ZOS Stadionausbau – Break-even-Rechner
# Start: shiny::runApp()
# ------------------------------------------------------------

format_pound <- function(x, digits = 0) {
  paste0(
    formatC(
      x,
      format = "f",
      digits = digits,
      big.mark = ".",
      decimal.mark = ","
    ),
    " £"
  )
}

format_number_de <- function(x, digits = 0) {
  formatC(
    x,
    format = "f",
    digits = digits,
    big.mark = ".",
    decimal.mark = ","
  )
}

ui <- fluidPage(
  tags$head(
    tags$meta(name = "viewport", content = "width=device-width, initial-scale=1.0"),
    tags$title("ZOS-Stadionrechner"),
    tags$style(HTML("
      :root {
        --orange: #ff9800;
        --orange-dark: #e58a00;
        --blue: #27475e;
        --blue-dark: #1d3547;
        --blue-light: #3e647e;
        --box-bg: #ffffff;
        --row-a: #f5f5f5;
        --row-b: #ebebeb;
        --border: #cccccc;
        --text: #333333;
        --muted: #777777;
      }

      * { box-sizing: border-box; }

      html, body { min-height: 100%; }

      body {
        margin: 0;
        background:
          linear-gradient(rgba(255,255,255,.50), rgba(255,255,255,.50)),
          repeating-linear-gradient(
            135deg,
            #dddddd 0,
            #dddddd 2px,
            #e8e8e8 2px,
            #e8e8e8 6px
          );
        color: var(--text);
        font-family: Arial, Helvetica, sans-serif;
        font-size: 13px;
      }

      .container-fluid { padding: 0; }

      .progress-line {
        height: 4px;
        background: var(--orange);
      }

      .header-bg {
        color: #ffffff;
        background: linear-gradient(180deg, rgba(39,71,94,.97), rgba(29,53,71,.99));
        border-bottom: 1px solid #142735;
        box-shadow: 0 2px 7px rgba(0,0,0,.28);
      }

      .header-main {
        width: min(1060px, calc(100% - 24px));
        margin: 0 auto;
        padding: 18px 0;
      }

      .page-title {
        margin: 0;
        color: #ffffff;
        font-size: 25px;
        font-weight: bold;
        text-align: center;
        text-shadow: 0 1px 1px rgba(0,0,0,.45);
      }

      .page-title span { color: var(--orange); }

      .main-container {
        width: min(1060px, calc(100% - 24px));
        margin: 18px auto 34px;
      }

      .mainbox {
        border: 1px solid #bfbfbf;
        background: var(--box-bg);
        box-shadow: 0 2px 7px rgba(0,0,0,.16);
      }

      .mainbox-content {
        padding: 18px 20px 24px;
      }

      .results-grid {
        display: grid;
        grid-template-columns: repeat(3, 1fr);
        border-left: 1px solid #d0d0d0;
        border-top: 1px solid #d0d0d0;
      }

      .result-box {
        min-height: 103px;
        padding: 13px;
        text-align: center;
        background: #f2f2f2;
        border-right: 1px solid #d0d0d0;
        border-bottom: 1px solid #d0d0d0;
      }

      .result-label {
        color: #666666;
        font-size: 11px;
        font-weight: bold;
        text-transform: uppercase;
      }

      .result-value {
        margin-top: 9px;
        color: var(--blue);
        font-size: 25px;
        font-weight: bold;
      }

      .result-value.orange { color: var(--orange-dark); }

      .result-detail {
        margin-top: 7px;
        color: #777777;
        font-size: 11px;
      }

      .result-text {
        padding: 14px;
        line-height: 1.6;
        background: #f5f5f5;
        border: 1px solid #d1d1d1;
        border-top: 0;
      }

      .result-text strong { color: var(--blue-dark); }

      .calculator-grid {
        display: grid;
        grid-template-columns: minmax(310px, .82fr) minmax(0, 1.45fr);
        gap: 18px;
        margin-top: 18px;
        align-items: stretch;
      }

      .input-box,
      .plot-box {
        border: 1px solid #d0d0d0;
        background: #ffffff;
      }

      .input-box {
        overflow: hidden;
      }

      .table-row {
        display: grid;
        grid-template-columns: minmax(155px, 1.1fr) minmax(125px, .9fr) 62px;
        align-items: center;
        min-height: 54px;
        background: var(--row-a);
        border-bottom: 1px solid #d7d7d7;
      }

      .table-row:nth-child(even) { background: var(--row-b); }

      .table-row:last-child { border-bottom: 0; }

      .table-column { padding: 8px 10px; }

      .table-column + .table-column {
        border-left: 1px solid #d4d4d4;
      }

      .table-label { font-weight: bold; }

      .form-group { margin: 0; }

      label {
        margin: 0;
        font-size: 13px;
      }

      .form-control {
        width: 100%;
        height: 32px;
        padding: 5px 8px;
        color: #333333;
        background: #ffffff;
        border: 1px solid #aaaaaa;
        border-radius: 0;
        box-shadow: inset 0 1px 2px rgba(0,0,0,.12);
        font-size: 13px;
      }

      .form-control:focus {
        border-color: var(--orange);
        box-shadow: 0 0 0 1px var(--orange);
      }

      .irs {
        margin-top: -3px;
      }

      .irs--shiny .irs-bar,
      .irs--shiny .irs-single {
        background: var(--orange);
        border-color: var(--orange-dark);
      }

      .irs--shiny .irs-handle {
        border-color: var(--orange-dark);
      }

      .unit {
        color: #555555;
        font-weight: bold;
        text-align: center;
      }

      .plot-box {
        height: 300px;
        min-height: 0;
        padding: 5px 8px 0;
        overflow: hidden;
      }

      .calculation-note {
        margin-top: 16px;
        padding: 10px 12px;
        color: #666666;
        background: #f2f2f2;
        border: 1px solid #d1d1d1;
        font-size: 11px;
        line-height: 1.5;
      }

      .shiny-output-error-validation {
        padding: 14px;
        color: #8f2622;
        background: #f9d9d7;
        border: 1px solid #dfaaa7;
      }

      @media (max-width: 820px) {
        .header-main,
        .main-container {
          width: calc(100% - 14px);
        }

        .mainbox-content {
          padding: 12px 10px 18px;
        }

        .results-grid {
          grid-template-columns: 1fr;
        }

        .calculator-grid {
          grid-template-columns: 1fr;
        }

        .table-row {
          grid-template-columns: 1fr;
          padding: 8px 10px;
        }

        .table-column {
          padding: 4px 0;
        }

        .table-column + .table-column {
          border-left: 0;
        }

        .unit {
          text-align: left;
        }

        .plot-box {
          height: 280px;
        }
      }
    "))
  ),

  div(class = "progress-line"),

  div(
    class = "header-bg",
    div(
      class = "header-main",
      tags$h1(
        class = "page-title",
        HTML("ZOS-<span>Stadionrechner</span>")
      )
    )
  ),

  div(
    class = "main-container",
    div(
      class = "mainbox",
      div(
        class = "mainbox-content",

        uiOutput("result_boxes"),
        uiOutput("result_text"),

        div(
          class = "calculator-grid",

          div(
            class = "input-box",

            div(
              class = "table-row",
              div(class = "table-column table-label", "Baukosten"),
              div(
                class = "table-column",
                numericInput("baukosten", NULL, 15000000, min = 1, step = 100000)
              ),
              div(class = "table-column unit", "£")
            ),

            div(
              class = "table-row",
              div(class = "table-column table-label", "Neue Plätze"),
              div(
                class = "table-column",
                numericInput("plaetze", NULL, 5000, min = 1, step = 100)
              ),
              div(class = "table-column unit", "Plätze")
            ),

            div(
              class = "table-row",
              div(class = "table-column table-label", "Auslastung"),
              div(
                class = "table-column",
                sliderInput(
                  "auslastung",
                  NULL,
                  min = 0,
                  max = 100,
                  value = 85,
                  step = 1,
                  post = " %"
                )
              ),
              div(class = "table-column unit", "%")
            ),

            div(
              class = "table-row",
              div(class = "table-column table-label", "Heimspiele"),
              div(
                class = "table-column",
                numericInput("heimspiele", NULL, 20, min = 1, step = 1)
              ),
              div(class = "table-column unit", "Saison")
            ),

            div(
              class = "table-row",
              div(class = "table-column table-label", "Einnahme je Zuschauer"),
              div(
                class = "table-column",
                numericInput(
                  "einnahme_pro_platz",
                  NULL,
                  44,
                  min = 0.01,
                  step = 1
                )
              ),
              div(class = "table-column unit", "£")
            )
          ),

          div(
            class = "plot-box",
            plotOutput("break_even_plot", height = "290px")
          )
        ),

        div(
          class = "calculation-note",
          "Berechnung: neue Plätze × Auslastung × Heimspiele × Einnahme pro Zuschauer."
        )
      )
    )
  )
)
server <- function(input, output, session) {

  calc <- reactive({
    validate(
      need(input$baukosten > 0, "Bitte Baukosten über 0 £ eingeben."),
      need(input$plaetze > 0, "Bitte mindestens einen neuen Platz eingeben."),
      need(input$heimspiele > 0, "Bitte mindestens ein Heimspiel eingeben."),
      need(input$einnahme_pro_platz > 0, "Bitte eine Einnahme pro Zuschauer über 0 £ eingeben.")
    )

    auslastung <- input$auslastung / 100
    zuschauer_pro_spiel <- input$plaetze * auslastung
    einnahmen_pro_spiel <- zuschauer_pro_spiel * input$einnahme_pro_platz
    einnahmen_pro_saison <- einnahmen_pro_spiel * input$heimspiele

    validate(
      need(einnahmen_pro_saison > 0, "Mit diesen Angaben entstehen keine zusätzlichen Einnahmen.")
    )

    break_even <- input$baukosten / einnahmen_pro_saison
    volle_saisons <- ceiling(break_even)
    max_saison <- max(10, volle_saisons + 3)
    saison <- 0:max_saison
    cashflow <- -input$baukosten + saison * einnahmen_pro_saison

    list(
      auslastung = auslastung,
      zuschauer_pro_spiel = zuschauer_pro_spiel,
      einnahmen_pro_spiel = einnahmen_pro_spiel,
      einnahmen_pro_saison = einnahmen_pro_saison,
      break_even = break_even,
      volle_saisons = volle_saisons,
      df = data.frame(saison = saison, cashflow = cashflow)
    )
  })

  output$result_boxes <- renderUI({
    x <- calc()

    div(
      class = "results-grid",
      div(
        class = "result-box",
        div(class = "result-label", "Break-even"),
        div(
          class = "result-value orange",
          paste0(format_number_de(x$break_even, 2), " Saisons")
        ),
        div(
          class = "result-detail",
          paste("nach", x$volle_saisons, "vollen Saisons refinanziert")
        )
      ),
      div(
        class = "result-box",
        div(class = "result-label", "Einnahmen pro Saison"),
        div(
          class = "result-value",
          format_pound(x$einnahmen_pro_saison)
        ),
        div(class = "result-detail", "durch die neuen Plätze")
      ),
      div(
        class = "result-box",
        div(class = "result-label", "Zusätzliche Zuschauer"),
        div(
          class = "result-value",
          format_number_de(x$zuschauer_pro_spiel)
        ),
        div(class = "result-detail", "je Heimspiel")
      )
    )
  })

  output$result_text <- renderUI({
    x <- calc()
    saison_wort <- if (x$volle_saisons == 1) "Saison" else "Saisons"

    div(
      class = "result-text",
      HTML(
        paste0(
          "Basierend auf den hinterlegten Eingaben erreicht die Investition von <strong>", format_pound(input$baukosten),
          "</strong> den rechnerischen Break-even nach <strong>",
          format_number_de(x$break_even, 2), " Saisons</strong>. ",
          "Damit ist der Stadionausbau nach <strong>", x$volle_saisons,
          " vollen ", saison_wort, "</strong> erstmals vollständig refinanziert. ",
          "Die erwarteten zusätzlichen Einnahmen betragen ",
          "<strong>", format_pound(x$einnahmen_pro_spiel),
          " pro Heimspiel</strong> beziehungsweise <strong>",
          format_pound(x$einnahmen_pro_saison),
          " pro Saison</strong>."
        )
      )
    )
  })

  output$break_even_plot <- renderPlot({
    x <- calc()
    df <- x$df

    ggplot(df, aes(x = saison, y = cashflow)) +
      geom_hline(
        yintercept = 0,
        colour = "#ff9800",
        linewidth = 0.9,
        linetype = "dashed"
      ) +
      geom_area(
        aes(y = pmax(cashflow, 0)),
        fill = "#4b8d44",
        alpha = 0.16
      ) +
      geom_area(
        aes(y = pmin(cashflow, 0)),
        fill = "#b34e48",
        alpha = 0.12
      ) +
      geom_line(
        colour = "#27475e",
        linewidth = 1.25
      ) +
      geom_point(
        colour = "#27475e",
        fill = "#ffffff",
        shape = 21,
        size = 2.7,
        stroke = 1
      ) +
      geom_vline(
        xintercept = x$break_even,
        colour = "#ff9800",
        linewidth = 0.8,
        linetype = "dotted"
      ) +
      annotate(
        "label",
        x = x$break_even,
        y = 0,
        label = paste0(
          "Break-even: ",
          format_number_de(x$break_even, 2),
          " Saisons"
        ),
        hjust = ifelse(x$break_even > max(df$saison) * .62, 1, 0),
        vjust = -0.6,
        colour = "#333333",
        fill = "#ffbf55",
        label.size = 0,
        fontface = "bold",
        size = 3.7
      ) +
      scale_x_continuous(
        breaks = pretty_breaks(),
        expand = expansion(mult = c(.02, .06))
      ) +
      scale_y_continuous(
        labels = label_number(
          scale_cut = cut_short_scale(),
          suffix = " £",
          big.mark = ".",
          decimal.mark = ","
        ),
        expand = expansion(mult = c(.08, .14))
      ) +
      labs(
        x = "Saison",
        y = "Kumulierter Cashflow"
      ) +
      theme_minimal(base_size = 12) +
      theme(
        plot.background = element_rect(fill = "#ffffff", colour = NA),
        panel.background = element_rect(fill = "#ffffff", colour = NA),
        panel.grid.major = element_line(colour = "#dddddd", linewidth = .45),
        panel.grid.minor = element_blank(),
        axis.text = element_text(colour = "#555555"),
        axis.title = element_text(colour = "#333333", face = "bold"),
        plot.margin = margin(12, 17, 12, 9)
      )
  }, res = 96)
}

shinyApp(ui, server)
