(() => {
  "use strict";

  const overlay = document.getElementById("loading-overlay");
  const frame = document.getElementById("zos-app");
  const status = document.getElementById("loading-status");
  const startedAt = Date.now();
  let finished = false;
  let lastTextIndex = -1;

  const loadingTexts = [
    "Molle schreibt gerade eine News...",
    "labbes lebt gerade unseren Traum...",
    "lolo erstellt gerade eine Auktion...",
    "Powl studiert gerade das Regelwerk...",
    "Jesse zählt gerade Geld...",
    "Olof verpflichtet gerade einen Schweden...",
    "BlauWeiss_4630 gewinnt gerade ein Spiel...",
    "Phaeton und Pape machen gerade den Deal des Jahres..."
  ];

  const setStatus = (text) => {
    if (status) status.textContent = text;
  };

  const showRandomLoadingText = () => {
    if (finished || loadingTexts.length === 0) return;

    let nextIndex = 0;
    if (loadingTexts.length > 1) {
      do {
        nextIndex = Math.floor(Math.random() * loadingTexts.length);
      } while (nextIndex === lastTextIndex);
    }

    lastTextIndex = nextIndex;
    setStatus(loadingTexts[nextIndex]);
  };

  showRandomLoadingText();
  const textTimer = window.setInterval(showRandomLoadingText, 2300);

  const reveal = () => {
    if (finished) return;
    finished = true;
    window.clearInterval(textTimer);

    frame?.classList.add("is-ready");

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

  const poll = window.setInterval(() => {
    const elapsed = Date.now() - startedAt;

    if (appLooksReady()) {
      window.clearInterval(poll);
      reveal();
      return;
    }

    if (elapsed > 45000) {
      window.clearInterval(poll);
      reveal();
    }
  }, 180);
})();
