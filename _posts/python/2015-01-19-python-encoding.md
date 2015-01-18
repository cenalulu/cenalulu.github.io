---
layout: article
title:  "关于Python的默认字符集"
categories: python
toc: true
ads: true
image:
    teaser: /teaser/charset.jpg
---

> 本文将简要介绍Python程序解析使用的字符集历史和配置方法。

> 背景： 在写脚本程序的时候难免会设计一些和中文相关的变量内容。这个时候对于一个python新手（包括我在内）来说如何配置python使之能够正确识别程序内的中文内容就会变得非常头疼。本文将会简要介绍python字符集的配置方法和一些相关历史信息


---

## Python的默认字符集

Python的默认字符集在几个大版本中有过改变，以下是各个版本的默认字符集列举：

- Python2.1及以前： latin1
- Python2.3及之后，Python2.5以前：latin1 （但是会对非ASCII字符集字符提出WARNING）
- Python2.5及以后：ASCII

此外在PEP上也有提议[在后续版本中将默认字符集调整为UTF-8](https://www.python.org/dev/peps/pep-3120/)


---

## 如何配置默认字符集(Python2.5以前)

配置Python当前脚本文件解析使用的默认字符集在2.5以前是很困难的。因为这些老版本不支持类似shebang的coding配置方式。虽然2.5以前的老版本已经过时了，这里还是提一下这些版本配置字符集的方法。具体配置原理是通过`sys.setdefaultencoding()`函数。但是纠结的是，这个函数`site.py`（一个在Python启动时自动运行的脚本）中被删除了。于是网上就出现了以下几种版本的方法：

- reload(sys)
- 修改`sitecustomize.py`配置全局默认字符集

两种方法都仅仅是能work，且不优雅。更具体的操作方式可以参看[stackoverflow上的讨论](http://stackoverflow.com/questions/2276200/changing-default-encoding-of-python)


---

## 如何配置默认字符集(Python2.5及以后)

`Python2.5`以后的默认字符集配置方式就简单了很多。只要在Shebang后面（即`#! /usr/bin/python`这一行之后), 紧跟上一行字符集配置行即可。字符集配置行的书写规则需要符合这么一个正则`coding[:=]\s*([-\w.]+)`。也就是说以下几种写法都可以生效：

{% highlight python %}
{% raw %}
#!/usr/bin/python
# coding=utf8
{% endraw %}
{% endhighlight %}

或者

{% highlight python %}
{% raw %}
#!/usr/bin/python
# -*- coding: utf8 -*-
{% endraw %}
{% endhighlight %}

更或者

{% highlight python %}
{% raw %}
#!/usr/bin/python
# vim: set fileencoding=<encoding name> :
{% endraw %}
{% endhighlight %}

这些都是可以work的



