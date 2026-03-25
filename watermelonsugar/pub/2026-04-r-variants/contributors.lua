local function names_para(people)
  if not people then return nil end
  local inlines = pandoc.List()
  for i, p in ipairs(people) do
    inlines:insert(pandoc.Str(pandoc.utils.stringify(p.name)))
    if i < #people then
      inlines:insert(pandoc.Str(","))
      inlines:insert(pandoc.Space())
    end
  end
  return inlines
end

local function make_credit_blocks(meta)
  local contrib = names_para(meta["x-contributor"])
  local reviewer = names_para(meta["x-reviewer"])
  if not contrib and not reviewer then return nil end

  local blocks = pandoc.List()

  local left = ""
  if contrib then
    left = "\\begin{minipage}[t]{0.45\\textwidth}\n\\textsc{Contributor}\\\\\n"
      .. pandoc.utils.stringify(pandoc.SmallCaps(contrib))
      .. "\n\\end{minipage}"
  end

  local right = ""
  if reviewer then
    right = "\\begin{minipage}[t]{0.45\\textwidth}\n\\textsc{Reviewer}\\\\\n"
      .. pandoc.utils.stringify(pandoc.SmallCaps(reviewer))
      .. "\n\\end{minipage}"
  end

  blocks:insert(pandoc.RawBlock("latex", left .. "\\hfill\n" .. right))

  local html_left = contrib and
    "<div><p><small><strong>Contributor</strong></small></p><p>"
    .. pandoc.utils.stringify(pandoc.SmallCaps(contrib)) .. "</p></div>" or ""

  local html_right = reviewer and
    "<div><p><small><strong>Reviewer</strong></small></p><p>"
    .. pandoc.utils.stringify(pandoc.SmallCaps(reviewer)) .. "</p></div>" or ""

  blocks:insert(pandoc.RawBlock("html",
    "<div style='display:flex;gap:2rem;'>" .. html_left .. html_right .. "</div>"))

  return blocks
end

function Pandoc(doc)
  local blocks = make_credit_blocks(doc.meta)
  if not blocks then return doc end
  for i = #blocks, 1, -1 do
    doc.blocks:insert(1, blocks[i])
  end
  return doc
end