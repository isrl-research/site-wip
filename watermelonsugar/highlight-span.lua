-- highlight-span.lua
function Span(el)
  if el.classes:includes("highlight") then
    return pandoc.RawInline("html", 
      "<mark class='scan-highlight'>" .. 
      pandoc.utils.stringify(el) .. 
      "</mark>"
    )
  end
end