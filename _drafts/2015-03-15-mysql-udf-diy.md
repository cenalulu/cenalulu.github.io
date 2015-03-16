---
layout: article
title: "Mysql Udf Diy"
modified:
categories: mysql
#excerpt:
#tags: []
#image:
#    feature: /teaser/xxx
#    teaser: /teaser/xxx
#    thumb:
date: 2015-03-15T15:07:30+08:00
---



> 文章欢迎转载，但转载时请保留本段文字，并置于文章的顶部
> 作者：卢钧轶(cenalulu)
> 本文原文地址：<http://cenalulu.github.io{{ page.url }}>


cp sql/udf_example.def sql/my_isprime.def

{% highlight c %}
{% raw %}
LIBRARY     my_isprime
VERSION     1.0
EXPORTS
    isprime_init
    isprime_deinit
    isprime
{% endraw %}
{% endhighlight %}

make my_isprime

C_MODE_START;
C_MODE_END;
否则
mysql [localhost] {msandbox} ((none)) > CREATE FUNCTION isprime RETURNS INT SONAME 'my_isprime.so';
ERROR 1127 (HY000): Can't find symbol 'isprime' in library

代码需要以下包裹，否则会出错
#ifdef HAVE_DLOPEN
#endif

drop function  if exists isprime;CREATE FUNCTION isprime RETURNS INT SONAME 'my_isprime.so';

gcc -bundle -o my_isprime.o my_isprime.c -I/data/percona-server-5.6.22-72.0/include/
