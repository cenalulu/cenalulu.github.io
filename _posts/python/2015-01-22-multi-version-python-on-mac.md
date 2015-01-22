---
layout: article
title:  "在Mac电脑上安装多版本的Python"
categories: python
toc: false
ads: true
#image:
#    teaser: /teaser/default.jpg
---

> 本文将介绍如何在Mac电脑上实现多个版本的Python共存及切换的方法

> 申明：本文是Stackoverflow的回答转载和翻译。[原文链接](http://stackoverflow.com/questions/18671253/how-can-i-use-homebrew-to-install-both-python-2-and-3-on-mac-mountain-lion)

## 具体方法

首先通过`homebrew`安装`pyenv`，之后的所有Python安装和管理通过`pyenv`进行。


{% highlight bash %}
{% raw %}
$ brew install pyenv
{% endraw %}
{% endhighlight %}

`pyenv`安装完以后，就可以选择性的进行Python环境安装了。下面已安装Python2.7为例：

{% highlight bash %}
{% raw %}
$ pyenv install 2.7.5
{% endraw %}
{% endhighlight %}

此外，你还可以通过`pyenv`查看目前系统中已经安装过的Python版本

{% highlight bash %}
{% raw %}
$ pyenv versions
{% endraw %}
{% endhighlight %}

如果需要在不同版本的Python间进行切换的话，使用以下命令：

{% highlight bash %}
{% raw %}
$ pyenv global 3.3.1
{% endraw %}
{% endhighlight %}

当然，你也可以让版本切换只对当前目录生效

{% highlight bash %}
{% raw %}
$ pyenv local 2.7.5
{% endraw %}
{% endhighlight %}
