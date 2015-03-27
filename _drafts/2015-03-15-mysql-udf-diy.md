---
layout: article
title: "0基础写一个属于自己的MySQL内置函数"
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

> 本文从写一个最简单的`hello_world()`MySQL内置函数开始，介绍MySQL UDF API和一些简单使用方法。

> 文章欢迎转载，但转载时请保留本段文字，并置于文章的顶部
> 作者：卢钧轶(cenalulu)
> 本文原文地址：<http://cenalulu.github.io{{ page.url }}>


## 准备

#### 知识准备

如果你还不太熟悉或者没有听过[MySQL UDF](http://dev.mysql.com/doc/refman/5.6/en/adding-functions.html)的话，可以先把它看做是和MySQL基本内置函数（例如：`max()`,`count()`等）是一样的。它的特别之处在于基本内置函数是在MySQL编译时就已经集成在MySQL Server内的。而`UDF`是可以以动态链接库形式在MySQL安装后，甚至是在MySQL运行的时候动态扩充的。那他和`CREATE FUNCTION BEGIN END`这种形式创建出的类似存储过程的函数有什么差别呢？答案是：运行速度。`CREATE FUNCTION`本质是一堆SQL的集合，在每次执行时需要做词法语法结构的解析，运行速度较慢；而`UDF`是C语言编写编译的，执行时无需额外的解析，效率损耗可以认为和基本内置函数是在一个数量级的。

#### 环境准备

在动手写第一个`hello_world()`自定义函数前，你需要以下准备：

- 一个正在运行着的MySQL
- 和该MySQL版本一致的源代码包（[下载地址](http://dev.mysql.com/downloads/mysql/)）
- 一个有`SUPER`权限的账号
- gcc编译环境

**注意：千万不要在任何生产/线上环境中运行以下任何一个示例。操作失误很可能会造成MySQL Crash**{: style="color: red"}


---


## 一个简单的Hello World

如果你和博主一样是一个急性子，在静下心学习`为什么`之前，总喜欢先知道`是什么`。那么就跟着我一起先Step by Step的为MySQL创建一个`hello_world`函数吧。这个`hello_world`函数仅仅是演示作用，他本质上没有任何意义。该函数不接受输入参数，返回一个`hello_world!`的字符串。

- 在任何一个目录下创建一个`hello_word_source.c`并将以下代码复制进去

{% highlight c %}
{% raw %}
#include <my_global.h>
#include <mysql.h>
#include <string.h>


#ifdef HAVE_DLOPEN


C_MODE_START;
my_bool hello_world_init(UDF_INIT *initid, UDF_ARGS *args, char *message);
void hello_world_deinit(UDF_INIT *initid);
char *hello_world(UDF_INIT *initid, UDF_ARGS *args,
        char *result, unsigned long *length,
            char *is_null, char *error);
C_MODE_END;



my_bool hello_world_init(UDF_INIT *initid, UDF_ARGS *args, char *message)
{
    return 0;
}

void hello_world_deinit(UDF_INIT *initid __attribute__((unused)))
{
}

char *hello_world(UDF_INIT *initid, UDF_ARGS *args,
        char *result, unsigned long *length,
            char *is_null, char *error)
{
    strcpy(result,"hello world!");
    *length=12;
    return result;

}

#endif
{% endraw %}
{% endhighlight %}


- 编译

用以下命令编译刚才创建的文件。注意`-I`选项后的目录路径按照实际情况修改，改成`准备`章节中下载的MySQL源码文件中`include`文件夹的绝对路径。
{% highlight bash %}
{% raw %}
gcc -bundle -o hello_world_source.so hello_world_source.c -I/data/percona-server-5.6.22-72.0/include/
{% endraw %}
{% endhighlight %}

- 确定MySQL的插件文件位置

{% highlight mysql %}
{% raw %}
mysql> show global variables like '%plugin%';
+---------------+--------------------------------+
| Variable_name | Value                          |
+---------------+--------------------------------+
| plugin_dir    | /data/5.6.22/lib/mysql/plugin/ |
+---------------+--------------------------------+
1 row in set (0.02 sec)
{% endraw %}
{% endhighlight %}

- 将编译后的文件复制到插件文件夹

{% highlight bash %}
{% raw %}
cp ./hello_world_source.so /data/5.6.22/lib/mysql/plugin/
{% endraw %}
{% endhighlight %}

- 在MySQL创建`hello_world`函数

{% highlight mysql %}
{% raw %}
mysql> drop function if exists hello_world; CREATE FUNCTION hello_world RETURNS STRING SONAME 'hello_world_source.so';
Query OK, 0 rows affected, 1 warning (0.01 sec)

Query OK, 0 rows affected (0.01 sec)

{% endraw %}
{% endhighlight %}

- 成功！

{% highlight mysql %}
{% raw %}
mysql> select hello_world();
+---------------+
| hello_world() |
+---------------+
| hello world!  |
+---------------+
1 row in set (0.01 sec)
{% endraw %}
{% endhighlight %}

## 代码分解

下面我们通过对上例代码的分解，来分析DIY一个MySQL UDF需要哪些基本元素。其实无论是简单的`hello_world`还是复杂的UDF，都只需要两大部分的代码。第一部分是：关键函数申明；第二部分是关键函数实现。

#### 关键函数申明

MySQL UDF内部实际上是通过命名规范来决定去调用哪个函数的。要创建一个UDF必须要申明并实现以下三个函数：

{% raw %}

- xxx_init()UDF_INIT *initid, UDF_ARGS *args, char *message
- xxx_deinit(UDF_INIT *initid)
- xxx(UDF_INIT *initid, UDF_ARGS *args, char *result, unsigned long *length, char *is_null, char *error)

{% endraw %}

**并且，这三个函数的申明必须包裹在`C_MODE_START;`和`C_MODE_END;`之间** {: style="color: red"}


## 实例二

否则
mysql [localhost] {msandbox} ((none)) > CREATE FUNCTION isprime RETURNS INT SONAME 'my_isprime.so';
ERROR 1127 (HY000): Can't find symbol 'isprime' in library

代码需要以下包裹，否则会出错
#ifdef HAVE_DLOPEN
#endif

drop function  if exists isprime;CREATE FUNCTION isprime RETURNS INT SONAME 'my_isprime.so';

gcc -bundle -o my_isprime.o my_isprime.c -I/data/percona-server-5.6.22-72.0/include/

## 性能测试
