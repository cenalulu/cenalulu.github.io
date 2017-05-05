---
layout: article
title: Shell进阶技巧系列 -- 1. 变量扩展
modified:
categories: 
#excerpt:
#tags: []
#image:
#    feature: /teaser/xxx
#    teaser: /teaser/xxx
#    thumb:
date: 2016-03-20T16:54:49+00:00
---



> 文章欢迎转载，但转载时请保留本段文字，并置于文章的顶部
> 作者：卢钧轶(cenalulu)
> 本文原文地址：<http://cenalulu.github.io{{ page.url }}>


## 1. 什么是变量扩展

所谓变量展开(即Parameter Expansion)，就是将`$`开头的变量，根据之后的表达式展开成对应的值的操作。听上去很深奥，其实很简单。举个例子:

{% highlight bash %}
{% raw %}
>>> var="I am var"
>>> echo $var 
I am var
{% endraw %}
{% endhighlight %}
这个其实就是最基础也最常用的变量展开。然而，无论是bash还是zsh他们所支持的变量展开功能强大到令你无法想象。由于作者目前是zsh的死忠，因此可能文中的某些例子会仅适用于zsh。
需要注意的是，如果你只是想获得某个变量中的值，常用的写法是`$var`。但是如果你想要使用本文中提到的任何变量扩展的话，记得在变量名及其表达式之外加上大括号，即形如`${var}`

## 2. 正文

### 2.1 基于索引的获取

语法: `${varname:offset:length}`

这里基于索引的值获取概念和python中的list取值概念一样。如果是`scalar`类型的变量，例如字符串那么索引便是以字符为单位，取出子字符串。如果是`array`类型的变量，那么取值则是把序号作为数组序号来处理。描述比较生涩，我们看个例子就比较容易理解了

*其中`str`是一个形如`IP:PORT`形式的字符串，如果我们事先知道端口为4位数的话，就可以用如下变量展开轻松的获得端口号 *

{% highlight bash %}
{% raw %}
>>>str="10.1.1.2:3307"
>>>echo ${str: -4}
3307
{% endraw %}
{% endhighlight %}


又例如我们有一个名为`my_array`的数组，想要取出除了第一个和最后一个之外的所有元素可以这么操作
{% highlight bash %}
{% raw %}
>>>my_array=(1 2 3 4 5)
>>>echo ${my_array:1:$((${#my_array}-2))}
2 3 4
{% endraw %}
{% endhighlight %}
可以发现这个例子中，不难发现，zsh中的索引不但支持显示的数字，而且还支持表达式，甚至是变量扩展的嵌套。我们简单的拆开分析下，其中`${#my_array}`本身即是一个变量扩展，代表了这个数组的长度也就是5。所以这个变量扩展相当于 `${my_array:1:3}`（注意，因为数组的序号是从0开始的）。


### 2.2 基于正则的替换

语法: `${varname//repr/subs/}`

虽然老版本的bash也有`${var%%}`和`${var##}`这样基于正则的变量内容替换，但是语法生涩且和我们常用的编程语言的语法差别太大。在平时使用中常常会需要差文档才能记起来该怎么用。而`search&match`形式的正则就相对来说就更容易记忆。

我们还是以刚才的IP端口为例子：为了实现同样取出端口号的目的，我们也可以使用正则变量扩展。

{% highlight bash %}
{% raw %}
1.1.1.1
>>>str="10.1.1.2:3307"
>>>echo ${str/[^:]*:/}
3307
>>>echo ${str/[^:]*:}
3307
{% endraw %}
{% endhighlight %}

可以看到如果是想把match到的字符串替换为空字符串的话，甚至可以省去最后一个`/`使表达式变得更简单。


### 2.3 变量前的Tag

除了POSIX标准内的变量扩展语法外，zsh还支持通过变量名前的flag来达到更多扩展的目的。

字符串分割：把变量内的值按照某个字符分割成数组。效果等同于`cut`
{% highlight bash %}
{% raw %}
>>> long_str="This is a very long string"
>>> echo ${${(s: :)long_str}[2]}
is
>>> echo $long_str | cut -d" " -f2
is
{% endraw %}
{% endhighlight %}


排序

{% highlight bash %}
{% raw %}
>>>str=`
>>>echo ${str: -4}
3307
{% endraw %}
{% endhighlight %}













Reference:
1. <http://wiki.bash-hackers.org/syntax/pe>
2. <http://zsh.sourceforge.net/Doc/Release/Expansion.html#Parameter-Expansion>
3. <http://zshwiki.org/home/scripting/paramflags>



