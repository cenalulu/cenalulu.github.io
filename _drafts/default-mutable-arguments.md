---
layout: article
title:  "Python函数参数默认值的陷阱和原理深究"
categories: python
toc: true
#image:
#    teaser: /mysql/mysql-tool.png
---


> 本文将介绍使用mutable对象作为Python函数参数默认值潜在的危害，以及其实现原理和设计目的


## 陷阱重现

我们就用实际的举例来演示我们今天所要讨论的主要内容。
下面一段代码定义了一个名为`generate_new_list_with`的函数。该函数的本意是在每次调用时都新建一个包含有给定`element`值的list。而实际运行结果如下: 

{% highlight python %}
{% raw %}
Python 2.7.9 (default, Dec 19 2014, 06:05:48)
[GCC 4.2.1 Compatible Apple LLVM 6.0 (clang-600.0.56)] on darwin
Type "help", "copyright", "credits" or "license" for more information.
>>> def generate_new_list_with(my_list=[], element=None):
...     my_list.append(element)
...     return my_list
...
>>> list_1 = generate_new_list_with(element=1)
>>> list_1
[1]
>>> list_2 = generate_new_list_with(element=2)
>>> list_2
[1, 2]
>>>
{% endraw %}
{% endhighlight %}

可见代码运行结果并不和我们预期的一样。`list_2`在函数的第二次调用时并没有得到一个新的list并填入2，而是在第一次调用结果的基础上append了一个2。为什么会发生这样在其他编程语言中简直就是设计bug一样的问题呢？


#### 准备知识：Python变量的实质


要了解这个问题的原因我们先需要一个准备知识：那就是Python变量到底是什么？
Python变量区别于其他编程语言的申明&赋值方式，采用的是创建&指向的类似于指针的方式实现的。即Python中的变量实际上是对值或者对象的一个指针（简单的说他们是值得一个名字）。我们来看一个例子。
{% highlight python %}
{% raw %}
p = 1
p = p+1
{% endraw %}
{% endhighlight %}
对于传统语言，上面这段代码的执行方式将会是，先在内存中申明一个`p`的变量，然后将`1`存入变量`p`所在内存。执行加法操作的时候得到`2`的结果，将`2`这个数值再次存入到`p`所在内存地址中。__可见整个执行过程中，变化的是变量`p`所在内存地址上的值__
上面这段代码中，Python实际上是现在执行内存中创建了一个`1`的对象，并将`p`指向了它。在执行加法操作的时候，实际上通过加法操作得到了一个`2`的新对象，并将`p`指向这个新的对象。__可见整个执行过程中，变化的是`p`指向的内存地址__


## 函数参数默认值陷阱的根本原因

我们先从一段摘录来解开这个陷阱的原因。下面是一段从[Python Common Gotchas](http://http://docs.python-guide.org/en/latest/writing/gotchas/)中摘录的原因解释：

```
Python’s default arguments are evaluated once when the function is defined, not each time the function is called (like it is in say, Ruby). This means that if you use a mutable default argument and mutate it, you will and have mutated that object for all future calls to the function as well.
```

可见如果参数默认值是在函数编译`compile`阶段就已经被确定。之后所有的函数调用时，该参数不过是指向该固定可变`mutable`对象的指针。如果调用函数时，没有显示指定传入参数值得话。那么所有这种情况下的该参数都会作为编译时创建的那个可变对象的一种别名存在。


## 为什么Python要这么设计
