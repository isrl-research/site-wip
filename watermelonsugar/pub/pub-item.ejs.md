```{=html}
<style>
  .pub-list { list-style: none; padding: 0; margin: 0; }
  .pub-card { margin-bottom: 1rem; padding: 1.5rem 2rem; background-color: #eeebe3; border-radius: 6px; }
  .pub-card:last-child { margin-bottom: 0; }
  .pub-meta { display: flex; align-items: center; gap: 0.6rem; margin-bottom: 0.6rem; flex-wrap: wrap; }
  .pub-docid { font-family: monospace; font-size: 0.72rem; color: #555; letter-spacing: 0.04em; }
  .pub-date { font-family: 'Source Sans 3', sans-serif; font-size: 0.72rem; color: #555; }
  .pub-badge { font-family: 'Source Sans 3', sans-serif; font-size: 0.65rem; font-weight: 600; letter-spacing: 0.08em; text-transform: uppercase; background-color: #f5e6a3; color: #5c4700; padding: 0.15em 0.55em; border-radius: 3px; }
  .pub-title { font-family: 'Source Sans 3', sans-serif; font-weight: 600; font-size: 1.05rem; letter-spacing: -0.01em; line-height: 1.35; margin: 0 0 0.5rem 0; }
  .pub-title a { color: #1a1a1a; text-decoration: none; }
  .pub-title a:hover { text-decoration: underline; }
  .pub-title a:focus-visible { outline: 2px solid #1a1a1a; outline-offset: 2px; border-radius: 2px; }
  .pub-authors { font-family: 'Source Serif 4', serif; font-size: 0.875rem; color: #444; margin: 0 0 0.9rem 0; }
  .pub-footer { display: flex; align-items: center; gap: 1.25rem; flex-wrap: wrap; }
  .pub-doi { font-family: 'Source Sans 3', sans-serif; font-size: 0.78rem; color: #444; text-decoration: none; }
  .pub-doi:hover { text-decoration: underline; }
  .pub-doi:focus-visible { outline: 2px solid #1a1a1a; outline-offset: 2px; border-radius: 2px; }
  .pub-license { font-family: 'Source Sans 3', sans-serif; font-size: 0.78rem; color: #555; }
  @media (max-width: 600px) {
    .pub-card { padding: 1.1rem 1.25rem; }
    .pub-title { font-size: 0.98rem; }
  }
</style>

<ul class="pub-list" role="list">
<% for (const item of items) { %>
<li class="pub-card">
  <article>

    <div class="pub-meta" aria-label="Publication metadata">
      <% if (item['doc-id']) { %>
      <span class="pub-docid"><%= item['doc-id'] %></span>
      <% } %>
      <% if (item.date) { %>
      <span class="pub-date" aria-label="Published <%= item.date %>">· <%= item.date %></span>
      <% } %>
      <% if (item.draft) { %>
      <span class="pub-badge" role="note" aria-label="Draft — not yet peer reviewed">Draft</span>
      <% } else if (item.subtitle) { %>
      <span class="pub-badge" role="note"><%= item.subtitle %></span>
      <% } %>
    </div>

    <h3 class="pub-title">
      <a href="<%- item.path %>"><%= item.title %></a>
    </h3>

    <% if (item.author) { %>
    <p class="pub-authors"><%= item.author %></p>
    <% } %>

    <div class="pub-footer">
      <% if (item.doi && !item.doi.includes('[record-id]')) { %>
      <a class="pub-doi"
         href="https://doi.org/<%= item.doi %>"
         target="_blank"
         rel="noopener noreferrer"
         aria-label="DOI <%= item.doi %>, opens in new tab">doi:<%= item.doi %> <span aria-hidden="true">→</span></a>
      <% } %>
      <% if (item.license) { %>
      <span class="pub-license"><%= item.license %></span>
      <% } %>
    </div>

  </article>
</li>
<% } %>
</ul>
```
