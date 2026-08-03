(() => {
  "use strict";

  const overlay = document.getElementById("loading-overlay");
  const frame = document.getElementById("zos-app");
  const status = document.getElementById("loading-status");
  const startedAt = Date.now();
  let finished = false;

  const setStatus = (text) => { if (status) status.textContent = text; };

  const reveal = () => {
    if (finished) return;
    finished = true;
    setStatus("Berechnung ist bereit.");
    window.setTimeout(() => {
      overlay?.classList.add("is-hidden");
      overlay?.setAttribute("aria-busy", "false");
      frame?.focus({ preventScroll: true });
    }, 320);
  };

  const appLooksReady = () => {
    try {
      const win = frame.contentWindow;
      const doc = frame.contentDocument;
      if (!win || !doc || !doc.body) return false;

      const shinyConnected = Boolean(
        win.Shiny &&
        win.Shiny.shinyapp &&
        win.Shiny.shinyapp.$socket &&
        win.Shiny.shinyapp.$socket.readyState === 1
      );

      const busy =
        doc.documentElement.classList.contains("shiny-busy") ||
        doc.body.classList.contains("shiny-busy") ||
        Boolean(doc.querySelector(".shiny-busy"));

      const visibleApp = Boolean(
        doc.querySelector(".container-fluid, .main-container, #shiny-disconnected-overlay")
      );

      return visibleApp && shinyConnected && !busy;
    } catch (_) {
      return false;
    }
  };

  frame.addEventListener("load", () => {
    setStatus("Rechenmodell wird gestartet …");
  });

  const poll = window.setInterval(() => {
    const elapsed = Date.now() - startedAt;

    if (elapsed > 4500) setStatus("Diagramm und Eingaben werden geladen …");
    if (elapsed > 10000) setStatus("Fast geschafft …");

    if (appLooksReady()) {
      window.clearInterval(poll);
      reveal();
    }

    // Sicherheitsnetz: Das Overlay darf bei ungewöhnlichen Browsern nicht dauerhaft stehen bleiben.
    if (elapsed > 30000) {
      window.clearInterval(poll);
      reveal();
    }
  }, 250);
})();
