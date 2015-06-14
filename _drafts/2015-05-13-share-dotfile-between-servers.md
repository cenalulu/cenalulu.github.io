---
layout: article
title: "Share Dotfile Between Servers"
modified:
categories: 
#excerpt:
#tags: []
#image:
#    feature: /teaser/xxx
#    teaser: /teaser/xxx
#    thumb:
date: 2015-05-13T21:21:56-07:00
---



> 文章欢迎转载，但转载时请保留本段文字，并置于文章的顶部
> 作者：卢钧轶(cenalulu)
> 本文原文地址：<http://cenalulu.github.io{{ page.url }}>


## 安装

brew tap thoughtbot/formulae
brew install rcm


rcup / rcdn / mkrc / lsrc

{% highlight bash %}
{% raw %}
git clone <git_addr>
git add . 
git commit -m 'first commit'
git push origin
{% endraw %}
{% endhighlight %}


如何创建依赖环境的dotfile： http://soledadpenades.com/2013/05/25/using-environment-variables-for-configuring-vim/
