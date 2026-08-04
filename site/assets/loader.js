(() => {
  "use strict";

  const overlay = document.getElementById("loading-overlay");
  const frame = document.getElementById("zos-app");
  const status = document.getElementById("loading-status");
  const startedAt = Date.now();
  let finished = false;

  const setStatus = (text) => {
    if (status) status.textContent = text;
  };

  const reveal = () => {
    if (finished) return;
    finished = true;
    setStatus("Berechnung ist bereit.");

    // Zuerst die fertige App unter dem weiterhin deckenden Overlay einblenden.
    frame?.classList.add("is-ready");

    // Erst danach das Overlay ausblenden. Dadurch sind auch mobil keine
    // Shinylive-Waben oder weißen Zwischenzustände sichtbar.
    window.setTimeout(() => {
      overlay?.classList.add("is-hidden");
      overlay?.setAttribute("aria-busy", "false");
      frame?.focus({ preventScroll: true });
    }, 220);
  };

  const appLooksReady = () => {
    try {
      const doc = frame?.contentDocument;
      if (!doc?.body) return false;

      const main = doc.querySelector(".main-container");
      const plotOutput = doc.querySelector("#break_even_plot");
      const plotImage = plotOutput?.querySelector("img");

      const busy =
        doc.documentElement.classList.contains("shiny-busy") ||
        doc.body.classList.contains("shiny-busy") ||
        Boolean(doc.querySelector(".shiny-busy"));

      const plotReady = Boolean(
        plotImage &&
        plotImage.complete &&
        plotImage.naturalWidth > 0 &&
        plotImage.naturalHeight > 0
      );

      return Boolean(main && plotOutput && plotReady && !busy);
    } catch (_) {
      return false;
    }
  };

  frame?.addEventListener("load", () => {
    setStatus("Rechenmodell wird gestartet …");
  });

  const poll = window.setInterval(() => {
    const elapsed = Date.now() - startedAt;

    if (elapsed > 4200) setStatus("Diagramm und Eingaben werden geladen …");
    if (elapsed > 10500) setStatus("Fast geschafft …");

    if (appLooksReady()) {
      window.clearInterval(poll);
      reveal();
      return;
    }

    // Sicherheitsnetz für Browser, die den Bildstatus anders melden.
    // Das iframe bleibt bis dahin unsichtbar, sodass keine Waben durchscheinen.
    if (elapsed > 45000) {
      window.clearInterval(poll);
      reveal();
    }
  }, 180);
})();
