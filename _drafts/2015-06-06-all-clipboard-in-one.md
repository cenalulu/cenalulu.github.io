---
layout: article
title: "All Clipboard in One"
modified:
categories: 
#excerpt:
#tags: []
#image:
#    feature: /teaser/xxx
#    teaser: /teaser/xxx
#    thumb:
date: 2015-06-06T23:03:06-07:00
---



> 文章欢迎转载，但转载时请保留本段文字，并置于文章的顶部
> 作者：卢钧轶(cenalulu)
> 本文原文地址：<http://cenalulu.github.io{{ page.url }}>



{% highlight bash %}
{% raw %}
To have launchd start clipper at login:
    ln -sfv /usr/local/opt/clipper/*.plist ~/Library/LaunchAgents
Then to load clipper now:
    launchctl load ~/Library/LaunchAgents/homebrew.mxcl.clipper.plist
Or, if you don't want/need launchctl, you can just run:
    clipper
{% endraw %}
{% endhighlight %}


