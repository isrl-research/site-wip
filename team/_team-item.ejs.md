```{=html}
<% for (const item of items) { %>
<div style="margin-bottom: 1.5rem; padding-bottom: 1.5rem; border-bottom: 1px solid #ddd;">

  <% if (item.image) { %>
  <img src="<%- item.image %>" style="width:60px;height:60px;object-fit:cover;border-radius:50%;float:left;margin-right:1rem;" />
  <% } %>

  <strong><a href="<%- item.path %>"><%= item.title %></a></strong><br/>

  <% if (item.subtitle) { %><em><%= item.subtitle %></em><br/><% } %>
  <% if (item['team-role']) { %><small><strong>Role:</strong> <%= item['team-role'] %></small><br/><% } %>
  <% if (item['team-track']) { %><small><strong>Team:</strong> <%= item['team-track'] %></small><br/><% } %>
  <% if (item.description) { %><p style="margin-top:0.4rem;"><%= item.description %></p><% } %>

  <div style="clear:both;"></div>
</div>
<% } %>
```