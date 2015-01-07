---
layout: archive
permalink: /linux/
title: "Latest Posts in *linux*"
excerpt: "Intresting things in the linux world"
---

<div class="tiles">
{% for post in site.posts %}
	{% if post.categories contains 'linux' %}
		{% include post-grid.html %}
	{% endif %}
{% endfor %}
</div><!-- /.tiles -->
