```{=html}
<style>
  .pub-filters { display: flex; flex-wrap: wrap; gap: 0.5rem; margin-bottom: 1.75rem; }
  .pub-filter-btn {
    font-family: 'Source Sans 3', sans-serif; font-size: 0.78rem;
    background: none; border: 1px solid #c0b8a8; border-radius: 3px;
    padding: 0.25em 0.75em; cursor: pointer; color: #555;
    transition: background 0.1s, color 0.1s;
  }
  .pub-filter-btn:hover { background: #eeebe3; color: #1a1a1a; }
  .pub-filter-btn.active { background: #1a1a1a; color: #f7f6f2; border-color: #1a1a1a; }
  .pub-filter-btn:focus-visible { outline: 2px solid #1a1a1a; outline-offset: 2px; }
  .pub-list { list-style: none; padding: 0; margin: 0; }
  .pub-entry { padding: 1.75rem 0; border-bottom: 1px solid #d8d4ca; }
  .pub-entry:first-child { border-top: 1px solid #d8d4ca; }
  .pub-entry[hidden] { display: none; }
  .pub-byline { font-family: 'Source Sans 3', sans-serif; font-size: 0.8rem; color: #1a1a1a; margin: 0 0 0.5rem 0; display: flex; flex-wrap: wrap; gap: 0.4rem; align-items: baseline; }
  .pub-byline-sep { color: #999; }
  .pub-type { color: #777; }
  .pub-draft { font-size: 0.72rem; font-weight: 600; letter-spacing: 0.03em; text-transform: uppercase; background: #e8e0d0; color: #5a4e3a; border-radius: 3px; padding: 0.15em 0.5em; font-style: normal; }
  .pub-title { font-family: 'Source Serif 4', serif; font-size: 1.1rem; font-weight: 400; line-height: 1.4; margin: 0 0 0.45rem 0; }
  .pub-title a { color: #1a1a1a; text-decoration: underline; text-decoration-color: #c0b8a8; text-underline-offset: 3px; }
  .pub-title a:hover { text-decoration-color: #1a1a1a; }
  .pub-title a:focus-visible { outline: 2px solid #1a1a1a; outline-offset: 2px; border-radius: 1px; }
  .pub-authors { font-family: 'Source Serif 4', serif; font-size: 0.9rem; color: #1a1a1a; margin: 0 0 0.6rem 0; }
  .pub-links { font-family: 'Source Sans 3', sans-serif; font-size: 0.8rem; color: #555; display: flex; flex-wrap: wrap; gap: 1rem; align-items: center; }
  .pub-doi { color: #555; text-decoration: none; }
  .pub-doi:hover { text-decoration: underline; }
  .pub-doi:focus-visible { outline: 2px solid #1a1a1a; outline-offset: 2px; border-radius: 1px; }
  @media (max-width: 600px) {
    .pub-title { font-size: 1rem; }
    .pub-entry { padding: 1.25rem 0; }
  }
</style>

<%
  const typeMap = { R: 'Report', DS: 'Dataset', M: 'Methods Note', D: 'Data Paper', B: 'Book' };
  function getType(docId) {
    if (!docId) return null;
    const match = (docId + '').match(/iSRL-\d{2}-\d{2}-([A-Za-z]+)-/i);
    return match ? (typeMap[match[1].toUpperCase()] || null) : null;
  }
  const presentTypes = [...new Set(items.map(i => getType(i['doc-id'])).filter(Boolean))];
%>

<% if (presentTypes.length > 1) { %>
<div class="pub-filters" role="group" aria-label="Filter publications by type">
  <button class="pub-filter-btn active" data-filter="all" onclick="pubFilter(this, 'all')">All</button>
  <% for (const t of presentTypes) { %>
  <button class="pub-filter-btn" data-filter="<%- t %>" onclick="pubFilter(this, '<%- t %>')"><%= t %></button>
  <% } %>
</div>
<% } %>

<ul class="pub-list" role="list" id="pub-list">
<% for (const item of items) { %>
<% const pubType = getType(item['doc-id']); %>
<li class="pub-entry" data-type="<%- pubType || '' %>">
  <article>

    <p class="pub-byline">
      <% if (item['doc-id']) { %><span><%= item['doc-id'] %></span><% } %>
      <% if (pubType) { %><span class="pub-byline-sep" aria-hidden="true">·</span><span class="pub-type"><%= pubType %></span><% } %>
      <% if (item.date) { %><span class="pub-byline-sep" aria-hidden="true">·</span><span><%= item.date %></span><% } %>
      <% if (item.draft) { %><span class="pub-draft" role="note">Draft – WIP</span><% } %>
    </p>

    <h3 class="pub-title">
      <a href="<%- item.path %>"><%= item.title %></a>
    </h3>

    <% if (item.author) { %>
    <p class="pub-authors"><%= item.author %></p>
    <% } %>

    <div class="pub-links">
      <% if (item.doi && !item.doi.includes('[record-id]')) { %>
      <a class="pub-doi"
         href="https://doi.org/<%= item.doi %>"
         target="_blank"
         rel="noopener noreferrer"
         aria-label="DOI <%= item.doi %>, opens in new tab">doi:<%= item.doi %></a>
      <% } %>
      <% if (item.license) { %><span><%= item.license %></span><% } %>
    </div>

  </article>
</li>
<% } %>
</ul>

<script>
function pubFilter(btn, type) {
  document.querySelectorAll('.pub-filter-btn').forEach(b => b.classList.remove('active'));
  btn.classList.add('active');
  document.querySelectorAll('#pub-list .pub-entry').forEach(el => {
    el.hidden = type !== 'all' && el.dataset.type !== type;
  });
}
</script>
```
