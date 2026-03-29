# Typesetting SOP — `pub/` Folder

Working standard operating procedure for the typesetting pass across all papers in `watermelonsugar/pub/`. The reference implementation for all frontmatter decisions is `2026-04-r-variants/index.qmd`. Do not restructure that file.

---

## 1. Overview

| Folder | Task |
|--------|------|
| `2026-02-r-regdelta` | LaTeX → QMD conversion + metadata standardisation |
| `2026-02-r-scfood` | LaTeX → QMD conversion + metadata standardisation |
| `2026-02-ds-variants` | Metadata standardisation + Zenodo abstract + dataset embed |
| `2026-02-b-encyclopedia` | Metadata standardisation only |
| `2026-02-d-emfjustify` | Metadata audit (already has good frontmatter) |
| `2026-02-m-groundtruth` | Metadata audit |
| `2026-02-r-emf` | Metadata audit |
| `2026-04-m-caas` | Metadata audit |
| `2026-04-r-variants` | Metadata audit (reference implementation — do not restructure) |

---

## 2. Canonical frontmatter template

Reference implementation: `2026-04-r-variants/index.qmd`. All files must conform to this shape:

```yaml
---
title: "Full Paper Title Here"
author:
  - name: Lalitha A R
    affiliation: iSRL
    orcid: 0009-0001-7466-3531
    email: lalithaar.research@gmail.com
    corresponding: true
x-contributor:
  - name: [Co-author / RA name if applicable]
    role: [their role, e.g. Research Assistant]
  - name: Hitha
    role: Typesetting
x-reviewer:
  - name: [Reviewer name if applicable]
doc-id: iSRL-YY-MM-[Type]-[Topic]   # e.g. iSRL-26-02-R-RegDelta
date: [Month YYYY]
doi: 10.5281/zenodo.[record-id]
license: "CC BY"
citation:
  type: report
  publisher: iSRL
  number: [doc-id repeated, e.g. iSRL-26-02-R-RegDelta]
format:
  html:
    toc: true
    number-sections: true
  pdf:
    toc: true
    number-sections: true
bibliography: references.bib
draft: true
draft-mode: visible
---
```

**Field notes:**
- `author` uses singular key (not `authors`) — check carefully; some placeholder files use `authors` (wrong)
- `x-contributor` / `x-reviewer` are iSRL custom fields — keep them, they are processed by `contributors.lua` in elaborate builds
- `doc-id` pattern: `iSRL-[2-digit year]-[2-digit month]-[Type initial]-[Topic slug]`
- `citation.type` is always `report` for iSRL working papers
- DOIs for each paper are listed in Section 7 below

---

## 3. Within-document cross-references (CRITICAL)

**Do NOT use `[@...]` for in-document elements. That syntax is only for bibliography citations.**

Quarto uses a `@label` system for cross-referencing elements within the document.

### Sections

Tag a heading:
```markdown
## Background {#sec-background}
```
Reference it elsewhere:
```markdown
As discussed in @sec-background, ...
```

### Tables

Tag a table:
```markdown
| Column A | Column B |
|----------|----------|
| value    | value    |

: Caption text here {#tbl-delta}
```
Reference it:
```markdown
See @tbl-delta for the full breakdown.
```

### Figures

```markdown
![Caption text](path/to/image.png){#fig-pipeline}
```
Reference: `@fig-pipeline`

### Equations

```markdown
$$
E = mc^2
$$ {#eq-energy}
```
Reference: `@eq-energy`

**Summary rule:** prefix = `sec-`, `tbl-`, `fig-`, `eq-` depending on element type. Always starts with `@` in text, always has `{#prefix-label}` on the element definition.

---

## 4. Bibliography citations

For citing published works / references in the `.bib` file:
```markdown
This has been established in prior work [@FSSAI_Label_2020].
Multiple citations: [@FSSAI_Label_2020; @DelhiHC_RamGaua_2022]
```

The `.bib` file format already in place should not be changed. When converting from LaTeX, map `\cite{key}` → `[@key]`.

---

## 5. LaTeX → QMD conversion guide (regdelta and scfood only)

### 5.1 Document structure

| LaTeX | Quarto Markdown |
|-------|----------------|
| `\section{Title}` | `## Title {#sec-title-slug}` |
| `\subsection{Title}` | `### Title {#sec-title-slug}` |
| `\subsubsection{Title}` | `#### Title` |
| `\textit{text}` | `*text*` |
| `\textbf{text}` | `**text**` |
| `\emph{text}` | `*text*` |
| `\footnote{text}` | `[^1]` with `[^1]: text` at section end |

### 5.2 Citations

| LaTeX | Quarto |
|-------|--------|
| `\cite{key}` | `[@key]` |
| `\citep{key}` | `[@key]` |
| `\citet{key}` | `@key` (inline author-year) |

Convert `\thebibliography` / `\bibitem` entries to proper `.bib` format in `references.bib`. Template for a regulation entry:
```bibtex
@misc{FSSAI_Label_2020,
  author = {{Food Safety and Standards Authority of India}},
  title  = {Food Safety and Standards (Labelling and Display) Regulations, 2020},
  year   = {2020},
  url    = {https://...}
}
```

### 5.3 Tables

Convert `tabular` + `booktabs` tables to markdown pipe tables:
```markdown
| Column A | Column B | Column C |
|----------|----------|----------|
| value    | value    | value    |

: Caption text {#tbl-label}
```
For `longtable`, use the same pipe table format — Quarto handles long tables natively in HTML/PDF.

Replace `Table~\ref{tab:x}` in text with `@tbl-x`.

### 5.4 Delete on conversion

Remove the entire LaTeX preamble (`\documentclass` through `\begin{document}`), `\maketitle`, `\end{document}`, and the `thebibliography` block (replaced by `.bib` file + YAML `bibliography:` field).

---

## 6. Dataset page: 2026-02-ds-variants

This folder corresponds to Zenodo record **10.34740/KAGGLE/DSV/14783287** — *Indian Food Ingredients & Label Variants*.

**Abstract to paste into the page** (place in a fenced div after the frontmatter):
```markdown
::: {.abstract}
## Abstract {.unnumbered}

This dataset maps over 2,500 regional ingredient naming variations observed on Indian food packaging, linking label variants to standardised categories. The work evolved from a technical data-cleaning exercise into a robust infrastructure model that preserves regional conventions while enabling coordination with regulatory, trade, and health systems. Diversity in labelling is treated not as noise but as signal; the layered architecture enables machine-readable alignment with ITC-HS trade nomenclature, FSSAI classifications, and INS/Codex identifiers.
:::
```

**Dataset embed** (after abstract): Once the CSV/JSON files are placed in the folder (ask Lalitha for file path), use Quarto's `embed` code snippet:

````markdown
```{python}
import pandas as pd
df = pd.read_csv("variants.csv")  # update filename
df.head(10)
```
````

Or for JSON:

````markdown
```{python}
import json, pandas as pd
with open("variants.json") as f:
    data = json.load(f)
pd.DataFrame(data).head(10)
```
````

`freeze: true` is already set in `_quarto.yml` so the output will be cached — no Python environment needed at build time once run once.

> **Note for typesetter:** Ask Lalitha for the actual CSV/JSON filename and path before writing this section. The Zenodo DOI for embedding is `10.34740/KAGGLE/DSV/14783287`.

---

## 7. Per-paper DOI reference

| Folder | Zenodo DOI |
|--------|-----------|
| `2026-02-m-groundtruth` | 10.5281/zenodo.18741725 |
| `2026-02-r-regdelta` | 10.5281/zenodo.18719394 |
| `2026-02-r-emf` | 10.5281/zenodo.18714527 |
| `2026-02-d-emfjustify` | 10.5281/zenodo.18713318 |
| `2026-02-ds-variants` | 10.34740/KAGGLE/DSV/14783287 |
| `2026-02-r-scfood` | 10.5281/zenodo.18651646 |
| `2026-02-b-encyclopedia` | 10.5281/zenodo.18650863 |

---

## 8. Checklist per file

Before marking a file done, verify:
- [ ] `author` key (singular, not `authors`)
- [ ] All four required author sub-fields present: name, affiliation, orcid, corresponding
- [ ] `x-contributor` block includes typesetter name with `role: Typesetting`
- [ ] `doc-id`, `date`, `doi`, `license`, `citation` block all present
- [ ] `format` block has both `html` and `pdf` with `toc: true` + `number-sections: true`
- [ ] No `[@...]` used for section/table/figure references (only for bibliography)
- [ ] All internal cross-refs use `@sec-`, `@tbl-`, `@fig-`, `@eq-` prefixes
- [ ] Placeholder author "Norah Jones" and citation `[@knuth84]` removed
- [ ] `bibliography: references.bib` present

---

## Complexity notes

- `scfood` is the heaviest conversion (~22 pages, 20 references, longtable). Budget ~3–4 hours.
- `regdelta` is lighter (~10 pages, 1 table, 8 refs). Budget ~2 hours.
- Metadata-only files: ~15–20 min each.
- Dataset page: ~1 hour (mainly the embed + abstract drop-in).

The main risk in conversion is cross-references — make sure every `\label{}/\ref{}` pair gets converted correctly to the `{#tbl-x}` / `@tbl-x` Quarto equivalents. Recommend doing one section at a time and checking `quarto preview` to confirm references render.
