-- review-layer.lua
-- Injects the iSRL review bar into draft pages only.

local _draft = false
local _title = "Untitled"

function Meta(meta)
  _draft = meta.draft and pandoc.utils.stringify(meta.draft) == "true"
  _title = meta.title and pandoc.utils.stringify(meta.title) or "Untitled"
  return meta
end

function Pandoc(doc)
  if not _draft then return doc end

  local html = [[
    <link rel="stylesheet" href="/review-layer.css">
    <script>window._reviewPageTitle = "]] .. _title:gsub('"', '\\"') .. [[";</script>
    <div id="isrl-review-bar">
      <button id="btn-review-mode" onclick="ReviewLayer.toggleReviewMode()">Review</button>
      <button id="btn-finish-export" onclick="ReviewLayer.exportYAML()" style="display:none">Finish Review &amp; Export</button>
      <button id="btn-view-review" onclick="ReviewLayer.openViewMode()">View Review</button>
      <input type="file" id="review-yaml-input" accept=".yml,.yaml" style="display:none">
      <span id="review-mode-label"></span>
    </div>
    <script src="/review-layer.js"></script>
  ]]

  table.insert(doc.blocks, pandoc.RawBlock("html", html))
  return doc
end
