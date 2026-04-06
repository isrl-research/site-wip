-- contributors.lua
-- Renders x-contributor and x-reviewer metadata fields inside Quarto's
-- title-block .quarto-title-meta grid, styled to match author/affiliation columns.
-- Each entry supports: name, affiliation, role (optional).

local function render_person(p)
  local name  = pandoc.utils.stringify(p.name or "")
  local affil = p.affiliation and pandoc.utils.stringify(p.affiliation) or nil
  local role  = p.role  and pandoc.utils.stringify(p.role)  or nil

  local html = '<p class="author" style="margin:0 0 0.1em 0;">' .. name .. '</p>'
  if affil then
    html = html .. '<p style="font-size:0.82em;color:#555;margin:0 0 0.5em 0;font-style:italic;">' .. affil .. '</p>'
  end
  if role then
    html = html .. '<p style="font-size:0.82em;color:#555;margin:0 0 0.5em 0;font-style:italic;">' .. role .. '</p>'
  end

  -- LaTeX
  local tex = name
  if affil then tex = tex .. " \\textit{\\small (" .. affil .. ")}" end
  if role  then tex = tex .. " [" .. role  .. "]" end

  return html, tex
end

-- Returns an inner <div> (one grid column) — not a full .quarto-title-meta wrapper.
local function make_section(label, people)
  if not people or #people == 0 then return nil, nil end

  local html_items = ""
  local tex_items  = ""
  for _, p in ipairs(people) do
    local h, t = render_person(p)
    html_items = html_items .. h
    tex_items  = tex_items .. t .. "\\\\\n"
  end

  local html = '<div>'
    .. '<div class="quarto-title-meta-heading">' .. label .. '</div>'
    .. '<div class="quarto-title-meta-contents">' .. html_items .. '</div>'
    .. '</div>'

  local tex = "\\textsc{" .. label .. "}\\\\\n" .. tex_items

  return html, tex
end

function Pandoc(doc)
  local contrib_html, contrib_tex = make_section("Contributors", doc.meta["x-contributor"])
  local review_html,  review_tex  = make_section("Reviewers",    doc.meta["x-reviewer"])

  if not contrib_html and not review_html then return doc end

  -- HTML: append columns into the existing .quarto-title-meta grid via script
  local inner = (contrib_html or "") .. (review_html or "")
  -- Escape backslashes and single quotes for embedding in a JS string
  inner = inner:gsub("\\", "\\\\"):gsub("'", "\\'"):gsub("\n", "")
  local script = "<script>\n"
    .. "document.addEventListener('DOMContentLoaded', function() {\n"
    .. "  var meta = document.querySelector('#title-block-header .quarto-title-meta');\n"
    .. "  if (!meta) return;\n"
    .. "  meta.insertAdjacentHTML('beforeend', '" .. inner .. "');\n"
    .. "});\n"
    .. "</script>"
  doc.blocks:insert(1, pandoc.RawBlock("html", script))

  -- LaTeX: keep minipage approach
  local tex = ""
  if contrib_tex then
    tex = tex .. "\\begin{minipage}[t]{0.45\\textwidth}\n" .. contrib_tex .. "\\end{minipage}"
  end
  if review_tex then
    if tex ~= "" then tex = tex .. "\\hfill\n" end
    tex = tex .. "\\begin{minipage}[t]{0.45\\textwidth}\n" .. review_tex .. "\\end{minipage}"
  end
  if tex ~= "" then
    doc.blocks:insert(1, pandoc.RawBlock("latex", tex))
  end

  return doc
end