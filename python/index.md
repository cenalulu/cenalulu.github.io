---
layout: archive
permalink: /python/
title: "Latest Posts in *python*"
excerpt: "What I've learnt, especially through Project Euler & Codeforce"
---

<div class="tiles">
{% for post in site.posts %}
	{% if post.categories contains 'python' %}
		{% include post-grid.html %}
	{% endif %}
{% endfor %}
</div><!-- /.tiles -->
