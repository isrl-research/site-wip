/* review-layer.js — iSRL in-browser review tool */
const ReviewLayer = (() => {
  const DB_NAME = "isrl-review";
  const STORE_NAME = "annotations";
  const REVIEWER_KEY = "isrl-review-reviewer";
  let db = null;
  let reviewModeActive = false;

  // ── IndexedDB ──────────────────────────────────────────────────────────────

  function openDB() {
    return new Promise((resolve, reject) => {
      const req = indexedDB.open(DB_NAME, 1);
      req.onupgradeneeded = (e) => {
        const store = e.target.result.createObjectStore(STORE_NAME, {
          keyPath: "id",
          autoIncrement: true,
        });
        store.createIndex("pageUrl", "pageUrl", { unique: false });
      };
      req.onsuccess = (e) => resolve(e.target.result);
      req.onerror = (e) => reject(e.target.error);
    });
  }

  async function getDB() {
    if (!db) db = await openDB();
    return db;
  }

  async function saveAnnotationToDB(text, comment) {
    const database = await getDB();
    return new Promise((resolve, reject) => {
      const tx = database.transaction(STORE_NAME, "readwrite");
      tx.objectStore(STORE_NAME).add({
        pageUrl: location.href,
        text,
        comment,
        timestamp: new Date().toISOString(),
      });
      tx.oncomplete = resolve;
      tx.onerror = (e) => reject(e.target.error);
    });
  }

  async function getAnnotationsForPage() {
    const database = await getDB();
    return new Promise((resolve, reject) => {
      const tx = database.transaction(STORE_NAME, "readonly");
      const index = tx.objectStore(STORE_NAME).index("pageUrl");
      const req = index.getAll(location.href);
      req.onsuccess = (e) => resolve(e.target.result);
      req.onerror = (e) => reject(e.target.error);
    });
  }

  // ── DOM helpers ────────────────────────────────────────────────────────────

  function getContentRoot() {
    return (
      document.querySelector(".quarto-body") ||
      document.querySelector("main") ||
      document.body
    );
  }

  /**
   * Walk text nodes under `root` and wrap every occurrence of `text` with a
   * <mark> element. Returns true if at least one match was wrapped.
   */
  function wrapTextInDOM(root, text, cssClass, comment, annotationId) {
    if (!text) return false;
    let found = false;
    const walker = document.createTreeWalker(root, NodeFilter.SHOW_TEXT);
    const nodesToProcess = [];
    let node;
    while ((node = walker.nextNode())) {
      if (node.nodeValue.includes(text)) nodesToProcess.push(node);
    }
    nodesToProcess.forEach((textNode) => {
      const parent = textNode.parentNode;
      // Don't double-wrap inside existing marks
      if (parent && parent.tagName === "MARK") return;
      const parts = textNode.nodeValue.split(text);
      if (parts.length < 2) return;
      const frag = document.createDocumentFragment();
      parts.forEach((part, i) => {
        frag.appendChild(document.createTextNode(part));
        if (i < parts.length - 1) {
          const mark = document.createElement("mark");
          mark.className = cssClass;
          mark.dataset.comment = comment || "";
          mark.textContent = text;
          // Tooltip span
          if (comment) {
            const tip = document.createElement("span");
            tip.className = "review-tooltip";
            tip.textContent = comment;
            mark.appendChild(tip);
          }
          // Delete button (live highlights only)
          if (annotationId != null) {
            const del = document.createElement("button");
            del.className = "review-delete-btn";
            del.setAttribute("aria-label", "Delete annotation");
            del.textContent = "×";
            del.onclick = (e) => { e.stopPropagation(); deleteAnnotation(annotationId); };
            mark.appendChild(del);
          }
          frag.appendChild(mark);
          found = true;
        }
      });
      parent.replaceChild(frag, textNode);
    });
    return found;
  }

  // ── Highlight rendering ────────────────────────────────────────────────────

  async function renderHighlights() {
    const annotations = await getAnnotationsForPage();
    const root = getContentRoot();
    // Remove existing live highlights before re-rendering
    root
      .querySelectorAll("mark.review-highlight")
      .forEach((m) => {
        const parent = m.parentNode;
        parent.replaceChild(document.createTextNode(m.textContent), m);
        parent.normalize();
      });
    annotations.forEach(({ id, text, comment }) => {
      wrapTextInDOM(root, text, "review-highlight", comment, id);
    });
    updateExportButtonVisibility(annotations.length > 0);
  }

  function renderHighlightsFromData(annotations) {
    const root = getContentRoot();
    // Remove existing view highlights
    root
      .querySelectorAll("mark.view-highlight")
      .forEach((m) => {
        const parent = m.parentNode;
        parent.replaceChild(document.createTextNode(m.textContent), m);
        parent.normalize();
      });
    annotations.forEach(({ text, comment }) => {
      wrapTextInDOM(root, text, "view-highlight", comment);
    });
  }

  // ── Comment popup ──────────────────────────────────────────────────────────

  function removePopup() {
    const existing = document.getElementById("review-comment-popup");
    if (existing) existing.remove();
  }

  function showCommentPopup(selectedText, x, y) {
    removePopup();
    const popup = document.createElement("div");
    popup.id = "review-comment-popup";
    popup.className = "review-comment-popup";
    popup.style.left = Math.min(x, window.innerWidth - 320) + "px";
    popup.style.top = y + window.scrollY + "px";

    const textarea = document.createElement("textarea");
    textarea.placeholder = "Add a comment (optional)…";
    textarea.rows = 3;

    const btnRow = document.createElement("div");
    btnRow.className = "review-popup-buttons";

    const saveBtn = document.createElement("button");
    saveBtn.textContent = "Save";
    saveBtn.className = "review-popup-save";
    saveBtn.onclick = async () => {
      removePopup();
      await saveAnnotation(selectedText, textarea.value.trim());
    };

    const cancelBtn = document.createElement("button");
    cancelBtn.textContent = "Cancel";
    cancelBtn.className = "review-popup-cancel";
    cancelBtn.onclick = removePopup;

    btnRow.appendChild(saveBtn);
    btnRow.appendChild(cancelBtn);
    popup.appendChild(textarea);
    popup.appendChild(btnRow);
    document.body.appendChild(popup);
    textarea.focus();
  }

  // ── Selection handler ──────────────────────────────────────────────────────

  function handleSelection(e) {
    const sel = window.getSelection();
    if (!sel || sel.isCollapsed || sel.toString().trim() === "") return;
    const selectedText = sel.toString().trim();
    const range = sel.getRangeAt(0);
    const rect = range.getBoundingClientRect();
    showCommentPopup(selectedText, rect.left, rect.bottom + 8);
  }

  // ── Save ───────────────────────────────────────────────────────────────────

  async function saveAnnotation(text, comment) {
    await saveAnnotationToDB(text, comment);
    await renderHighlights();
  }

  async function deleteAnnotation(id) {
    const database = await getDB();
    await new Promise((resolve, reject) => {
      const tx = database.transaction(STORE_NAME, "readwrite");
      tx.objectStore(STORE_NAME).delete(id);
      tx.oncomplete = resolve;
      tx.onerror = (e) => reject(e.target.error);
    });
    await renderHighlights();
  }

  // ── Export YAML ────────────────────────────────────────────────────────────

  function slugify(str) {
    return str
      .toLowerCase()
      .replace(/[^a-z0-9]+/g, "-")
      .replace(/^-|-$/g, "");
  }

  async function exportYAML() {
    const annotations = await getAnnotationsForPage();
    if (!annotations.length) {
      alert("No annotations to export.");
      return;
    }
    const title = window._reviewPageTitle || document.title || "page";
    const date = new Date().toISOString().split("T")[0];
    const reviewer = getReviewerName();
    const lines = [
      `# iSRL Review Export`,
      `# Page: ${title}`,
      `# Date: ${date}`,
      ...(reviewer ? [`# Reviewer: ${reviewer}`] : []),
      ``,
      `annotations:`,
    ];
    annotations.forEach(({ text, comment }) => {
      lines.push(`  - text: "${text.replace(/"/g, '\\"')}"`);
      lines.push(`    comment: "${(comment || "").replace(/"/g, '\\"')}"`);
    });
    const yaml = lines.join("\n") + "\n";
    const blob = new Blob([yaml], { type: "text/yaml" });
    const a = document.createElement("a");
    a.href = URL.createObjectURL(blob);
    a.download = `review-${slugify(title)}.yml`;
    a.click();
    URL.revokeObjectURL(a.href);
  }

  // ── View mode (load YAML) ──────────────────────────────────────────────────

  function openViewMode() {
    const input = document.getElementById("review-yaml-input");
    if (!input) return;
    input.onchange = (e) => {
      const file = e.target.files[0];
      if (!file) return;
      const reader = new FileReader();
      reader.onload = (ev) => loadYAML(ev.target.result);
      reader.readAsText(file);
      input.value = ""; // reset so same file can be reloaded
    };
    input.click();
  }

  function loadYAML(content) {
    const re = /- text: "([^"\\]*(?:\\.[^"\\]*)*)"\s+comment: "([^"\\]*(?:\\.[^"\\]*)*)"/g;
    const annotations = [];
    let match;
    while ((match = re.exec(content)) !== null) {
      annotations.push({
        text: match[1].replace(/\\"/g, '"'),
        comment: match[2].replace(/\\"/g, '"'),
      });
    }
    if (!annotations.length) {
      alert("No annotations found in this file.");
      return;
    }
    renderHighlightsFromData(annotations);
  }

  // ── Reviewer name ──────────────────────────────────────────────────────────

  function getReviewerName() {
    return localStorage.getItem(REVIEWER_KEY) || "";
  }

  function showNamePrompt(onConfirm) {
    const existing = document.getElementById("review-name-popup");
    if (existing) existing.remove();

    const popup = document.createElement("div");
    popup.id = "review-name-popup";
    popup.className = "review-comment-popup review-name-popup";

    const label = document.createElement("p");
    label.className = "review-name-label";
    label.textContent = "Your name (saved for this session):";

    const input = document.createElement("input");
    input.type = "text";
    input.className = "review-name-input";
    input.placeholder = "e.g. Priya Sharma";
    input.value = getReviewerName();

    const btnRow = document.createElement("div");
    btnRow.className = "review-popup-buttons";

    const confirmBtn = document.createElement("button");
    confirmBtn.textContent = "Start reviewing";
    confirmBtn.className = "review-popup-save";
    confirmBtn.onclick = () => {
      const name = input.value.trim();
      if (!name) { input.focus(); return; }
      localStorage.setItem(REVIEWER_KEY, name);
      popup.remove();
      onConfirm();
    };

    const cancelBtn = document.createElement("button");
    cancelBtn.textContent = "Cancel";
    cancelBtn.className = "review-popup-cancel";
    cancelBtn.onclick = () => popup.remove();

    // Allow Enter to confirm
    input.addEventListener("keydown", (e) => {
      if (e.key === "Enter") confirmBtn.click();
      if (e.key === "Escape") cancelBtn.click();
    });

    btnRow.appendChild(confirmBtn);
    btnRow.appendChild(cancelBtn);
    popup.appendChild(label);
    popup.appendChild(input);
    popup.appendChild(btnRow);
    document.body.appendChild(popup);
    input.focus();
    input.select();
  }

  // ── Review mode toggle ─────────────────────────────────────────────────────

  function updateExportButtonVisibility(hasAnnotations) {
    const btn = document.getElementById("btn-finish-export");
    if (btn) btn.style.display = hasAnnotations && reviewModeActive ? "" : "none";
  }

  function activateReviewMode() {
    reviewModeActive = true;
    document.body.classList.add("review-mode-active");
    const reviewer = getReviewerName();
    const label = document.getElementById("review-mode-label");
    if (label) label.textContent = reviewer ? `Reviewing as ${reviewer}` : "Review mode ON";
    document.addEventListener("mouseup", handleSelection);
    renderHighlights();
  }

  function toggleReviewMode() {
    if (!reviewModeActive) {
      // Ask for name before activating; if already stored, prompt is pre-filled
      showNamePrompt(activateReviewMode);
    } else {
      reviewModeActive = false;
      document.body.classList.remove("review-mode-active");
      const label = document.getElementById("review-mode-label");
      if (label) label.textContent = "";
      document.removeEventListener("mouseup", handleSelection);
      removePopup();
      updateExportButtonVisibility(false);
    }
  }

  // ── Init ───────────────────────────────────────────────────────────────────

  function init() {
    // Pre-open DB so first interaction is fast
    getDB().catch(() => {});
  }

  document.addEventListener("DOMContentLoaded", init);

  return {
    toggleReviewMode,
    exportYAML,
    openViewMode,
  };
})();
