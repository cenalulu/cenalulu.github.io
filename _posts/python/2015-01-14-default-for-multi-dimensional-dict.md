---
layout: article
title:  "Python中避免在给多维数组赋值之前判断key是否存在的方法"
categories: python
toc: true
ads: true
image:
    teaser: /teaser/python.jpg
---


> Python在使用二维及多维数组（dict）时，每次赋值之前都需要判断一维及较小维度上的key是否存在。本文将介绍对于这种问题的解决方案

---

## 背景

Python中可以使用dict数据类型来实现二维及多维数组。但是在对dict类型的多维数组赋值时，相较其他语言需要预先额外判断一次低维度的key是否存在的操作。否则就会报`KeyException`（这种功能称为[Autovivification](http://en.wikipedia.org/wiki/Autovivification)），具体见下例：


{% highlight python %}
{% raw %}
#初始化一个数组，对[1,1]这个点赋值为0
two_dimensional_dict = {1: {1: 0}}

#此时如果我们想要对[2,2]这个点也赋值为0
#那么需要额外进行一次 if 2 in two_dimensional_dict的操作
#否则Python会raise KeyException

#以下语句会报错
two_dimensional_dict = {2: {2: 0}} 

#需要使用如下方式
if 2 in two_dimensional_dict:
    two_dimensional_dict = {2: {2: 0}} 
else:
    two_dimensional_dict{2} = {} 
    two_dimensional_dict = {2: {2: 0}} 
{% endraw %}
{% endhighlight %}

---

## 用colletions.defaultdict来实现二维数组

作为一个类库丰富的语言不应该接受有如此冗余代码存在的场景。于是求助google，果然在[stackoverflow上有解答](http://stackoverflow.com/questions/14867496/update-and-create-a-multi-dimensional-dictionary-in-python)。具体的方法就是用`collections.defaultdict`来替代`dict`两者的使用方法一致，除了前者在初始化时需要告知：当低维度key不存在时的default值。具体的使用方法如下：

{% highlight python %}
{% raw %}
from collections import defaultdict

#创建一个二维数组
#如果低维度key未初始化时的默认值是0
my_dict = defaultdict(defaultdict)
my_dict[1][1] += 1
#output: 1
print my_dict[1][1]
{% endraw %}
{% endhighlight %}


---

## 为多维数组配置一个非0的默认值

此外我们还可以创建默认值为非0的多维数组，只需在实例化时稍作改写。具体如下例：

{% highlight python %}
{% raw %}
from collections import defaultdict

#创建一个二维数组
#如果低维度key未初始化时的默认值是2
my_dict = defaultdict(lambda: defaultdict(lambda: 2))
my_dict[1][1] += 1
#output: 1
print my_dict[1][1]
{% endraw %}
{% endhighlight %}

### reference
1. [question on stackoverflow](http://stackoverflow.com/questions/14867496/update-and-create-a-multi-dimensional-dictionary-in-python)
2. [python-multi-dimensional-dict](http://slacy.com/blog/2010/05/python-multi-dimensional-dicts-using-defaultdict/)
3. [Autovivification](http://en.wikipedia.org/wiki/Autovivification)















