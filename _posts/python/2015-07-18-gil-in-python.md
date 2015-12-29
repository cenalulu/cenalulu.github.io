---
layout: article
title: "Python的GIL是什么鬼，多线程性能究竟如何"
categories: python
#excerpt:
#tags: []
image:
#    feature: /teaser/xxx
    teaser: /teaser/gil.jpg
#    thumb:
date: 2015-07-18T21:44:03+01:00
---


> 前言：博主在刚接触Python的时候时常听到GIL这个词，并且发现这个词经常和Python无法高效的实现多线程划上等号。本着不光要知其然，还要知其所以然的研究态度，博主搜集了各方面的资料，花了一周内几个小时的闲暇时间深入理解了下GIL，并归纳成此文，也希望读者能通过次本文更好且客观的理解GIL。

> 文章欢迎转载，但转载时请保留本段文字，并置于文章的顶部
> 作者：卢钧轶(cenalulu)
> 本文原文地址：<http://cenalulu.github.io{{ page.url }}>


## GIL是什么

首先需要明确的一点是`GIL`并不是Python的特性，它是在实现Python解析器(CPython)时所引入的一个概念。就好比C++是一套语言（语法）标准，但是可以用不同的编译器来编译成可执行代码。有名的编译器例如GCC，INTEL C++，Visual C++等。Python也一样，同样一段代码可以通过CPython，PyPy，Psyco等不同的Python执行环境来执行。像其中的JPython就没有GIL。然而因为CPython是大部分环境下默认的Python执行环境。所以在很多人的概念里CPython就是Python，也就想当然的把`GIL`归结为Python语言的缺陷。所以这里要先明确一点：GIL并不是Python的特性，Python完全可以不依赖于GIL

那么CPython实现中的GIL又是什么呢？GIL全称`Global Interpreter Lock`为了避免误导，我们还是来看一下官方给出的解释：

> In CPython, the global interpreter lock, or GIL, is a mutex that prevents multiple native threads from executing Python bytecodes at once. This lock is necessary mainly because CPython's memory management is not thread-safe. (However, since the GIL exists, other features have grown to depend on the guarantees that it enforces.)

好吧，是不是看上去很糟糕？一个防止多线程并发执行机器码的一个Mutex，乍一看就是个BUG般存在的全局锁嘛！别急，我们下面慢慢的分析。


---


## 为什么会有GIL

由于物理上得限制，各CPU厂商在核心频率上的比赛已经被多核所取代。为了更有效的利用多核处理器的性能，就出现了多线程的编程方式，而随之带来的就是线程间数据一致性和状态同步的困难。[即使在CPU内部的Cache也不例外](linux/all-about-cpu-cache/)，为了有效解决多份缓存之间的数据同步时各厂商花费了不少心思，也不可避免的带来了一定的性能损失。

Python当然也逃不开，为了利用多核，Python开始支持多线程。*而解决多线程之间数据完整性和状态同步的最简单方法自然就是加锁。* 于是有了GIL这把超级大锁，而当越来越多的代码库开发者接受了这种设定后，他们开始大量依赖这种特性（即默认python内部对象是thread-safe的，无需在实现时考虑额外的内存锁和同步操作）。

慢慢的这种实现方式被发现是蛋疼且低效的。但当大家试图去拆分和去除GIL的时候，发现大量库代码开发者已经重度依赖GIL而非常难以去除了。有多难？做个类比，像MySQL这样的“小项目”为了把Buffer Pool Mutex这把大锁拆分成各个小锁也花了从5.5到5.6再到5.7多个大版为期近5年的时间，并且仍在继续。MySQL这个背后有公司支持且有固定开发团队的产品走的如此艰难，那又更何况Python这样核心开发和代码贡献者高度社区化的团队呢？

所以简单的说GIL的存在更多的是历史原因。如果推到重来，多线程的问题依然还是要面对，但是至少会比目前GIL这种方式会更优雅。


---


## GIL的影响

从上文的介绍和官方的定义来看，GIL无疑就是一把全局排他锁。毫无疑问全局锁的存在会对多线程的效率有不小影响。甚至就几乎等于Python是个单线程的程序。
那么读者就会说了，全局锁只要释放的勤快效率也不会差啊。只要在进行耗时的IO操作的时候，能释放GIL，这样也还是可以提升运行效率的嘛。或者说再差也不会比单线程的效率差吧。理论上是这样，而实际上呢？Python比你想的更糟。

下面我们就对比下Python在多线程和单线程下得效率对比。测试方法很简单，一个循环1亿次的计数器函数。一个通过单线程执行两次，一个多线程执行。最后比较执行总时间。测试环境为双核的Mac pro。注：为了减少线程库本身性能损耗对测试结果带来的影响，这里单线程的代码同样使用了线程。只是顺序的执行两次，模拟单线程。


#### 顺序执行的单线程(single_thread.py)

{% highlight python %}
{% raw %}

#! /usr/bin/python

from threading import Thread
import time

def my_counter():
    i = 0
    for _ in range(100000000):
        i = i + 1
    return True

def main():
    thread_array = {}
    start_time = time.time()
    for tid in range(2):
        t = Thread(target=my_counter)
        t.start()
        t.join()
    end_time = time.time()
    print("Total time: {}".format(end_time - start_time))

if __name__ == '__main__':
    main()

{% endraw %}
{% endhighlight %}


#### 同时执行的两个并发线程(multi_thread.py)

{% highlight python %}
{% raw %}

#! /usr/bin/python

from threading import Thread
import time

def my_counter():
    i = 0
    for _ in range(100000000):
        i = i + 1
    return True

def main():
    thread_array = {}
    start_time = time.time()
    for tid in range(2):
        t = Thread(target=my_counter)
        t.start()
        thread_array[tid] = t
    for i in range(2):
        thread_array[i].join()
    end_time = time.time()
    print("Total time: {}".format(end_time - start_time))

if __name__ == '__main__':
    main()

{% endraw %}
{% endhighlight %}

下图就是测试结果

![测试结果一](/images/python/gil/test_result.jpg)

可以看到python在多线程的情况下居然比单线程整整慢了45%。按照之前的分析，即使是有GIL全局锁的存在，串行化的多线程也应该和单线程有一样的效率才对。那么怎么会有这么糟糕的结果呢？

让我们通过GIL的实现原理来分析这其中的原因。


---


## 当前GIL设计的缺陷


#### 基于pcode数量的调度方式

按照Python社区的想法，操作系统本身的线程调度已经非常成熟稳定了，没有必要自己搞一套。所以Python的线程就是C语言的一个pthread，并通过操作系统调度算法进行调度（例如linux是CFS）。为了让各个线程能够平均利用CPU时间，python会计算当前已执行的微代码数量，达到一定阈值后就强制释放GIL。而这时也会触发一次操作系统的线程调度（当然是否真正进行上下文切换由操作系统自主决定）。

伪代码

{% highlight c %}
while True:
    acquire GIL
    for i in 1000:
        do something
    release GIL
    /* Give Operating System a chance to do thread scheduling */
{% endhighlight %}

这种模式在只有一个CPU核心的情况下毫无问题。任何一个线程被唤起时都能成功获得到GIL（因为只有释放了GIL才会引发线程调度）。但当CPU有多个核心的时候，问题就来了。从伪代码可以看到，从`release GIL`到`acquire GIL`之间几乎是没有间隙的。所以当其他在其他核心上的线程被唤醒时，大部分情况下主线程已经又再一次获取到GIL了。这个时候被唤醒执行的线程只能白白的浪费CPU时间，看着另一个线程拿着GIL欢快的执行着。然后达到切换时间后进入待调度状态，再被唤醒，再等待，以此往复恶性循环。

PS：当然这种实现方式是原始而丑陋的，Python的每个版本中也在逐渐改进GIL和线程调度之间的互动关系。例如先尝试持有GIL在做线程上下文切换，在IO等待时释放GIL等尝试。但是无法改变的是GIL的存在使得操作系统线程调度的这个本来就昂贵的操作变得更奢侈了。
[关于GIL影响的扩展阅读](http://www.dabeaz.com/GIL/)

为了直观的理解GIL对于多线程带来的性能影响，这里直接借用的一张测试结果图（见下图）。图中表示的是两个线程在双核CPU上得执行情况。两个线程均为CPU密集型运算线程。绿色部分表示该线程在运行，且在执行有用的计算，红色部分为线程被调度唤醒，但是无法获取GIL导致无法进行有效运算等待的时间。
![GIL Performance](http://www.dabeaz.com/images/GIL_2cpu.png)
由图可见，GIL的存在导致多线程无法很好的立即多核CPU的并发处理能力。

那么Python的IO密集型线程能否从多线程中受益呢？我们来看下面这张测试结果。颜色代表的含义和上图一致。白色部分表示IO线程处于等待。可见，当IO线程收到数据包引起终端切换后，仍然由于一个CPU密集型线程的存在，导致无法获取GIL锁，从而进行无尽的循环等待。
![GIL IO Performance](http://www.dabeaz.com/images/GIL_ioclose.png)

简单的总结下就是：Python的多线程在多核CPU上，只对于IO密集型计算产生正面效果；而当有至少有一个CPU密集型线程存在，那么多线程效率会由于GIL而大幅下降。


---


## 如何避免受到GIL的影响

说了那么多，如果不说解决方案就仅仅是个科普帖，然并卵。GIL这么烂，有没有办法绕过呢？我们来看看有哪些现成的方案。


#### 用multiprocessing替代Thread

multiprocessing库的出现很大程度上是为了弥补thread库因为GIL而低效的缺陷。它完整的复制了一套thread所提供的接口方便迁移。唯一的不同就是它使用了多进程而不是多线程。每个进程有自己的独立的GIL，因此也不会出现进程之间的GIL争抢。

当然multiprocessing也不是万能良药。它的引入会增加程序实现时线程间数据通讯和同步的困难。就拿计数器来举例子，如果我们要多个线程累加同一个变量，对于thread来说，申明一个global变量，用thread.Lock的context包裹住三行就搞定了。而multiprocessing由于进程之间无法看到对方的数据，只能通过在主线程申明一个Queue，put再get或者用share memory的方法。这个额外的实现成本使得本来就非常痛苦的多线程程序编码，变得更加痛苦了。具体难点在哪有兴趣的读者可以扩展阅读[这篇文章](http://www.jeffknupp.com/blog/2013/06/30/pythons-hardest-problem-revisited/)


#### 用其他解析器

之前也提到了既然GIL只是CPython的产物，那么其他解析器是不是更好呢？没错，像JPython和IronPython这样的解析器由于实现语言的特性，他们不需要GIL的帮助。然而由于用了Java/C#用于解析器实现，他们也失去了利用社区众多C语言模块有用特性的机会。所以这些解析器也因此一直都比较小众。毕竟功能和性能大家在初期都会选择前者，`Done is better than perfect`。

#### 所以没救了么？

当然Python社区也在非常努力的不断改进GIL，甚至是尝试去除GIL。并在各个小版本中有了不少的进步。有兴趣的读者可以扩展阅读[这个Slide](http://www.dabeaz.com/python/UnderstandingGIL.pdf)
另一个改进[Reworking the GIL](https://mail.python.org/pipermail/python-dev/2009-October/093321.html)
- 将切换颗粒度从基于opcode计数改成基于时间片计数
- 避免最近一次释放GIL锁的线程再次被立即调度
- 新增线程优先级功能（高优先级线程可以迫使其他线程释放所持有的GIL锁）


## 总结

Python GIL其实是功能和性能之间权衡后的产物，它尤其存在的合理性，也有较难改变的客观因素。从本分的分析中，我们可以做以下一些简单的总结：
- 因为GIL的存在，只有IO Bound场景下得多线程会得到较好的性能
- 如果对并行计算性能较高的程序可以考虑把核心部分也成C模块，或者索性用其他语言实现
- GIL在较长一段时间内将会继续存在，但是会不断对其进行改进

#### Reference

[Python's hardest problem](http://www.jeffknupp.com/blog/2013/06/30/pythons-hardest-problem-revisited/)
[Official documents about GIL](https://wiki.python.org/moin/GlobalInterpreterLock)
[Revisiting thread priorities and the new GIL](http://dabeaz.blogspot.com/2010/02/revisiting-thread-priorities-and-new.html)
