```{=html}
<% for (const item of items) { %>
<div style="margin-bottom: 1rem; padding: 1.5rem 2rem; background-color: #eeebe3; border-radius: 6px;">

  <div style="display: flex; align-items: center; gap: 0.6rem; margin-bottom: 0.6rem; flex-wrap: wrap;">
    <% if (item['doc-id']) { %>
    <span style="font-family: monospace; font-size: 0.72rem; color: #666; letter-spacing: 0.04em;"><%= item['doc-id'] %></span>
    <% } %>
    <% if (item.date) { %>
    <span style="font-family: 'Source Sans 3', sans-serif; font-size: 0.72rem; color: #999;">·  <%= item.date %></span>
    <% } %>
    <% if (item.draft) { %>
    <span style="font-family: 'Source Sans 3', sans-serif; font-size: 0.65rem; font-weight: 600; letter-spacing: 0.08em; text-transform: uppercase; background-color: #f5e6a3; color: #7a5f00; padding: 0.15em 0.55em; border-radius: 3px;">Draft</span>
    <% } %>
    <% if (item.subtitle) { %>
    <span style="font-family: 'Source Sans 3', sans-serif; font-size: 0.65rem; font-weight: 600; letter-spacing: 0.08em; text-transform: uppercase; background-color: #f5e6a3; color: #7a5f00; padding: 0.15em 0.55em; border-radius: 3px;"><%= item.subtitle %></span>
    <% } %>
  </div>

  <h3 style="font-family: 'Source Sans 3', sans-serif; font-weight: 600; font-size: 1.05rem; letter-spacing: -0.01em; line-height: 1.35; margin: 0 0 0.5rem 0;">
    <a href="<%- item.path %>" style="color: #1a1a1a; text-decoration: none;"><%= item.title %></a>
  </h3>

  <% if (item.author) { %>
  <p style="font-family: 'Source Serif 4', serif; font-size: 0.875rem; color: #555; margin: 0 0 0.9rem 0;"><%= item.author %></p>
  <% } %>

  <div style="display: flex; align-items: center; gap: 1.25rem; flex-wrap: wrap;">
    <% if (item.doi && !item.doi.includes('[record-id]')) { %>
    <a href="https://doi.org/<%= item.doi %>" target="_blank" style="font-family: 'Source Sans 3', sans-serif; font-size: 0.78rem; color: #555; text-decoration: none;">doi:<%= item.doi %> →</a>
    <% } %>
    <% if (item.license) { %>
    <span style="font-family: 'Source Sans 3', sans-serif; font-size: 0.78rem; color: #999;"><%= item.license %></span>
    <% } %>
  </div>

</div>
<% } %>
```
