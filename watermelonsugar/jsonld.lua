-- jsonld.lua
-- Injects ScholarlyArticle or Dataset JSON-LD for publication pages.
-- Triggered only when frontmatter contains `doc-id`.

local json_encode

-- Minimal JSON encoder (handles strings, arrays, objects, nil)
local function encode_value(v)
  local t = type(v)
  if t == "string" then
    -- Escape special characters
    v = v:gsub('\\', '\\\\')
    v = v:gsub('"', '\\"')
    v = v:gsub('\n', '\\n')
    v = v:gsub('\r', '\\r')
    v = v:gsub('\t', '\\t')
    return '"' .. v .. '"'
  elseif t == "number" then
    return tostring(v)
  elseif t == "boolean" then
    return tostring(v)
  elseif t == "table" then
    return json_encode(v)
  else
    return "null"
  end
end

json_encode = function(tbl)
  -- Detect array vs object
  local is_array = #tbl > 0
  if is_array then
    local parts = {}
    for _, v in ipairs(tbl) do
      parts[#parts + 1] = encode_value(v)
    end
    return "[" .. table.concat(parts, ", ") .. "]"
  else
    local parts = {}
    for k, v in pairs(tbl) do
      if type(k) == "string" then
        parts[#parts + 1] = '"' .. k .. '": ' .. encode_value(v)
      end
    end
    return "{" .. table.concat(parts, ", ") .. "}"
  end
end

-- Map citation.type to schema.org @type
local function schema_type(citation_type)
  if citation_type == "dataset" then
    return "Dataset"
  else
    return "ScholarlyArticle"
  end
end

-- Extract plain text from a Pandoc Inlines list
local function inlines_to_string(inlines)
  if type(inlines) == "string" then return inlines end
  if type(inlines) ~= "table" then return "" end
  local parts = {}
  for _, el in ipairs(inlines) do
    if el.t == "Str" then
      parts[#parts + 1] = el.text
    elseif el.t == "Space" or el.t == "SoftBreak" then
      parts[#parts + 1] = " "
    elseif el.t == "Quoted" then
      parts[#parts + 1] = inlines_to_string(el.content)
    end
  end
  return table.concat(parts)
end

-- Safely get a string from metadata value
local function meta_string(val)
  if val == nil then return nil end
  if type(val) == "string" then return val end
  if type(val) == "table" then
    if val.t == "MetaInlines" then
      return inlines_to_string(val.c)
    elseif val.t == "MetaBlocks" then
      -- Flatten blocks to plain text (best effort)
      local parts = {}
      for _, blk in ipairs(val.c) do
        if blk.t == "Para" or blk.t == "Plain" then
          parts[#parts + 1] = inlines_to_string(blk.c)
        end
      end
      return table.concat(parts, " ")
    elseif val.t == "MetaString" then
      return val.c
    elseif val.t == "MetaBool" then
      return tostring(val.c)
    end
  end
  return nil
end

-- Safely get a list from metadata value
local function meta_list(val)
  if val == nil then return {} end
  if type(val) == "table" and val.t == "MetaList" then
    return val.c
  end
  return {}
end

-- Safely get a map from metadata value
local function meta_map(val)
  if val == nil then return {} end
  if type(val) == "table" and val.t == "MetaMap" then
    return val.c
  end
  return {}
end

function Meta(meta)
  -- Only run for publication pages (doc-id present)
  local doc_id = meta_string(meta["doc-id"])
  if not doc_id then return end

  local title       = meta_string(meta.title) or ""
  local description = meta_string(meta.description) or meta_string(meta.abstract) or ""
  local date_val    = meta_string(meta.date) or ""
  local doi         = meta_string(meta.doi) or ""
  local license_val = meta_string(meta.license) or ""

  -- Resolve @type
  local ctype = "report"
  local citation_meta = meta_map(meta.citation)
  if citation_meta["type"] then
    ctype = meta_string(citation_meta["type"]) or "report"
  end
  local at_type = schema_type(ctype)

  -- Build author array
  local authors = {}
  for _, a in ipairs(meta_list(meta.author)) do
    local amap = meta_map(a)
    local person = { ["@type"] = "Person" }
    local aname = meta_string(amap.name)
    if aname then person["name"] = aname end
    local orcid = meta_string(amap.orcid)
    if orcid and orcid ~= "" then
      person["identifier"] = "https://orcid.org/" .. orcid
    end
    local affil = meta_string(amap.affiliation)
    if affil then
      person["affiliation"] = { ["@type"] = "Organization", name = affil }
    end
    authors[#authors + 1] = person
  end

  -- Build identifier (DOI URL)
  local identifier = nil
  if doi and doi ~= "" and not doi:find("%[") then
    -- Skip placeholder DOIs containing brackets
    identifier = "https://doi.org/" .. doi
  end

  -- Resolve license URL
  local license_url = nil
  if license_val and license_val ~= "" then
    if license_val:match("^http") then
      license_url = license_val
    elseif license_val:lower():find("cc by 4") then
      license_url = "https://creativecommons.org/licenses/by/4.0/"
    elseif license_val:lower():find("cc by") then
      license_url = "https://creativecommons.org/licenses/by/4.0/"
    end
  end

  -- Assemble JSON-LD object
  local ld = {
    ["@context"] = "https://schema.org",
    ["@type"] = at_type,
    name = title,
  }
  if description ~= "" then ld.description = description end
  if date_val ~= "" then ld.datePublished = date_val end
  if identifier then ld.identifier = identifier end
  if license_url then ld.license = license_url end
  if #authors > 0 then ld.author = authors end
  ld.publisher = {
    ["@type"] = "Organization",
    name = "iSRL",
    url = "https://isrl-research.github.io"
  }
  ld.isPartOf = {
    ["@type"] = "WebSite",
    name = "iSRL",
    url = "https://isrl-research.github.io"
  }

  local json_str = json_encode(ld)
  local script_tag = '<script type="application/ld+json">\n' .. json_str .. '\n</script>'
  quarto.doc.include_text("in-header", script_tag)
end
