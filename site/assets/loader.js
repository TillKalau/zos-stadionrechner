(() => {
  "use strict";

  const overlay = document.getElementById("loading-overlay");
  const frame = document.getElementById("zos-app");
  const status = document.getElementById("loading-status");
  const startedAt = Date.now();
  let finished = false;
  let textQueue = [];

  const loadingTexts = [
    "Molle schreibt gerade eine News...",
    "labbes lebt gerade unseren Traum...",
    "lolo erstellt gerade eine Auktion...",
    "Powl studiert gerade das Regelwerk...",
    "Jesse zählt gerade Geld...",
    "Olof verpflichtet gerade einen Schweden...",
    "BlauWeiss_4630 gewinnt gerade ein Spiel...",
    "Phaeton und Pape machen gerade den Deal des Jahres...",
"Max arbeitet gerade mit KI..."
"Guardiola.#4 sammelt gerade Muscheln in Portugal...",
  ];

  const setStatus = (text) => {
    if (status) status.textContent = text;
  };

  const refillTextQueue = () => {
    textQueue = [...loadingTexts];

    for (let i = textQueue.length - 1; i > 0; i -= 1) {
      const j = Math.floor(Math.random() * (i + 1));
      [textQueue[i], textQueue[j]] = [textQueue[j], textQueue[i]];
    }
  };

  const showRandomLoadingText = () => {
    if (finished || loadingTexts.length === 0) return;

    if (textQueue.length === 0) {
      refillTextQueue();
    }

    setStatus(textQueue.shift());
  };

  showRandomLoadingText();
  const textTimer = window.setInterval(showRandomLoadingText, 4300);

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
