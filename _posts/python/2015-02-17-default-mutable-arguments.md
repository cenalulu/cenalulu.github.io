---
layout: article
title:  "Python函数参数默认值的陷阱和原理深究"
categories: python
toc: true
image:
    teaser: /teaser/python.jpg
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


要了解这个问题的原因我们先需要一个准备知识，那就是：Python变量到底是如何实现的？
Python变量区别于其他编程语言的申明&赋值方式，采用的是创建&指向的类似于指针的方式实现的。即Python中的变量实际上是对值或者对象的一个指针（简单的说他们是值得一个名字）。我们来看一个例子。
{% highlight python %}
{% raw %}
p = 1
p = p+1
{% endraw %}
{% endhighlight %}
对于传统语言，上面这段代码的执行方式将会是，先在内存中申明一个`p`的变量，然后将`1`存入变量`p`所在内存。执行加法操作的时候得到`2`的结果，将`2`这个数值再次存入到`p`所在内存地址中。__可见整个执行过程中，变化的是变量`p`所在内存地址上的值__
上面这段代码中，Python实际上是现在执行内存中创建了一个`1`的对象，并将`p`指向了它。在执行加法操作的时候，实际上通过加法操作得到了一个`2`的新对象，并将`p`指向这个新的对象。__可见整个执行过程中，变化的是`p`指向的内存地址__


---   


## 函数参数默认值陷阱的根本原因

一句话来解释：Python函数的参数默认值，是在编译阶段就绑定的。

现在，我们先从一段摘录来详细分析这个陷阱的原因。下面是一段从[Python Common Gotchas](http://http://docs.python-guide.org/en/latest/writing/gotchas/)中摘录的原因解释：

> Python’s default arguments are evaluated once when the function is defined, not each time the function is called (like it is in say, Ruby). This means that if you use a mutable default argument and mutate it, you will and have mutated that object for all future calls to the function as well.

可见如果参数默认值是在函数编译`compile`阶段就已经被确定。之后所有的函数调用时，如果参数不显示的给予赋值，那么所谓的参数默认值不过是一个指向那个在`compile`阶段就已经存在的对象的指针。如果调用函数时，没有显示指定传入参数值得话。那么所有这种情况下的该参数都会作为编译时创建的那个对象的一种别名存在。如果参数的默认值是一个不可变(`Imuttable`)数值，那么在函数体内如果修改了该参数，那么参数就会重新指向另一个新的不可变值。而如果参数默认值是和本文最开始的举例一样，是一个可变对象(`Muttable`)，那么情况就比较糟糕了。所有函数体内对于该参数的修改，实际上都是对`compile`阶段就已经确定的那个对象的修改。
对于这么一个陷阱在 [Python官方文档](https://docs.python.org/3/tutorial/controlflow.html#more-on-defining-functions)中也有特别提示：

> Important warning: The default value is evaluated only once. This makes a difference when the default is a mutable object such as a list, dictionary, or instances of most classes. For example, the following function accumulates the arguments passed to it on subsequent calls:


---


## 如何避免这个陷阱带来不必要麻烦

当然最好的方式是不要使用可变对象作为函数默认值。如果非要这么用的话，下面是一种解决方案。还是以文章开头的需求为例：
{% highlight python %}
{% raw %}
def generate_new_list_with(my_list=None, element=None):
    if my_list is None:
        my_list = []
    my_list.append(element)
    return my_list
{% endraw %}
{% endhighlight %}


---


## 为什么Python要这么设计

这个问题的答案在 [StackOverflow](http://stackoverflow.com/questions/1132941/least-astonishment-in-python-the-mutable-default-argument) 上可以找到答案。这里将得票数最多的答案最重要的部分摘录如下：

> Actually, this is not a design flaw, and it is not because of internals, or performance.
It comes simply from the fact that functions in Python are first-class objects, and not only a piece of code.
> As soon as you get to think into this way, then it completely makes sense: a function is an object being evaluated on its definition; default parameters are kind of "member data" and therefore their state may change from one call to the other - exactly as in any other object.
> In any case, Effbot has a very nice explanation of the reasons for this behavior in Default Parameter Values in Python.
I found it very clear, and I really suggest reading it for a better knowledge of how function objects work.

在这个回答中，答题者认为出于Python编译器的实现方式考虑，函数是一个内部一级对象。而参数默认值是这个对象的属性。在其他任何语言中，对象属性都是在对象创建时做绑定的。因此，函数参数默认值在编译时绑定也就不足为奇了。
然而，也有其他很多一些回答者不买账，认为即使是`first-class object`也可以使用`closure`的方式在执行时绑定。

> This is not a design flaw. It is a design decision; perhaps a bad one, but not an accident. The state thing is just like any other closure: a closure is not a function, and a function with mutable default argument is not a function. 

甚至还有反驳者抛开实现逻辑，单纯从设计角度认为：只要是违背程序猿基本思考逻辑的行为，都是设计缺陷！下面是他们的一些论调：
> Sorry, but anything considered "The biggest WTF in Python" is most definitely a design flaw. This is a source of bugs for everyone at some point, because no one expects that behavior at first - which means it should not have been designed that way to begin with.

> The phrases "this is not generally what was intended" and "a way around this is" smell like they're documenting a design flaw.

好吧，这么看来，如果没有来自于Python作者的亲自陈清，这个问题的答案就一直会是一个谜了。





