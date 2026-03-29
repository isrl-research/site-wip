```{=html}
<style>
  .pub-list { list-style: none; padding: 0; margin: 0; }
  .pub-entry { padding: 1.75rem 0; border-bottom: 1px solid #d8d4ca; }
  .pub-entry:first-child { border-top: 1px solid #d8d4ca; }
  .pub-byline { font-family: 'Source Sans 3', sans-serif; font-size: 0.8rem; color: #1a1a1a; margin: 0 0 0.5rem 0; display: flex; flex-wrap: wrap; gap: 0.4rem; align-items: baseline; }
  .pub-byline-sep { color: #999; }
  .pub-draft { font-style: italic; color: #888; }
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

<ul class="pub-list" role="list">
<% for (const item of items) { %>
<li class="pub-entry">
  <article>

    <p class="pub-byline">
      <% if (item['doc-id']) { %><span><%= item['doc-id'] %></span><% } %>
      <% if (item.date) { %><span class="pub-byline-sep" aria-hidden="true">·</span><span><%= item.date %></span><% } %>
      <% if (item.draft) { %><span class="pub-byline-sep" aria-hidden="true">·</span><span class="pub-draft" role="note" aria-label="work in progress">work in progress</span><% } %>
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
```
