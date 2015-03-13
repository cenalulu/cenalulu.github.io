---
layout: article
title: "All-about-cpu-cache"
modified:
categories: linux
#excerpt:
#tags: []
#image:
#    feature: /teaser/xxx
#    teaser: /teaser/xxx
#    thumb:
date: 2015-03-11T01:01:45+08:00
---

#### 为什么要有CPU Cache

#### 为什么要有多级CPU Cache

## 什么是Cache Line

理解了Cache Line的概念和上面那个测试后，就比较容易理解下面这个C语言中[常用的循环优化例子](http://qr.ae/ja9ov)
下面两段代码中，第一段代码在C语言中总是比第二段代码的执行速度要快。具体的原因相信你读了上面Cache Line的介绍后就很容易理解了。

{% highlight c %}
{% raw %}
for(int i = 0; i < n; i++) {
    for(int j = 0; j < n; j++) {
        int num;    
        //code
        arr[i][j] = num;
    }
}
{% endraw %}
{% endhighlight %}

{% highlight c %}
{% raw %}
for(int i = 0; i < n; i++) {
    for(int j = 0; j < n; j++) {
        int num;    
        //code
        arr[j][i] = num;
    }
}
{% endraw %}
{% endhighlight %}



#### 为什么Cache Line的大小事64Bytes

#### 你会怎么设计一个Cache

对于没有硬件基础的人，或者说大学没有好好学习基础电路和数字电路的人（比如[我](http://cenalulu.github.io/)），在理解目前流行的Cache的设计方式之前都会有这么一个疑问：

> 假设我们有一块4MB的区域用于缓存，每个缓存对象的唯一标识是它所在的物理内存地址。每个缓存对象大小是64Bytes，所有可以被缓存对象的大小总和（即物理内存总大小）为4GB。那么我们该如何设计这个缓存？

如果你和博主一样是一个脚本程序猿或程序猿的话，很显而易见的一种方式就是：把Cache设计成一个Hash数组。内存地址的Hash值作为数组的Index，缓存对象的值作为数组的Value。每次存取时，都把地址做一次Hash然后找到Cache中对应的位置操作即可。
这样的设计方式在高等语言中很常见，也显然很高效。因为Hash值得计算虽然耗时([10000个CPU Cycle左右](http://programmers.stackexchange.com/questions/49550/which-hashing-algorithm-is-best-for-uniqueness-and-speed))，但是相比程序中其他操作（上百万的CPU Cycle）来说可以忽略不计。而对于CPU Cache来说，本来其设计目标就是在几十CPU Cycle内获取到数据。如果访问效率是百万Cycle这个等级的话，还不如到Memory直接获取数据。当然，更重要的原因是在硬件上要实现Memory Address Hash的功能在成本上是非常高的。


#### 为什么Cache不能做成Fully Associative

Fully Associative 字面意思是全关联。在CPU Cache中的含义是：如果在一个Cache集内，任何一个内存地址的数据可以被缓存在任何一个Cache Line里，那么我们成这个cache是Fully Associative。从定义中我们可以得出这样的结论：给到一个内存地址，要知道他是否存在于Cache中，需要遍历所有Cache Line并比较缓存内容的内存地址。而Cache的本意就是为了在尽可能少得CPU Cycle内取到数据。那么想要设计一个快速的Fully Associative的Cache几乎是不可能的。

#### 为什么Cache不能做成Direct Mapped

和Fully Associative完全相反，使用Direct Mapped模式的Cache给定一个内存地址，就唯一确定了一条Cache Line。设计复杂度低且速度快。那么为什么Cache不使用这种模式呢？让我们来想象这么一种情况：一个拥有1M L2 Cache的32位CPU，每条Cache Line的大小为64Bytes。那么整个L2Cache被划为了`1M/64=16384`条Cache Line。我们为每条Cache Line从0开始编上号。同时64位CPU所能管理的内存地址范围是`2^32=4G`，那么Direct Mapped模式下，内存也被划为`4G/16384=256K`的小份。也就是说每256K的内存地址共享一条Cache Line。但是，这种模式下每条Cache Line的使用率如果要做到接近100%，就需要操作系统对于内存的分配和访问在地址上也是近乎平均的。而与我们的意愿相反，为了减少内存碎片和实现便捷，操作系统更多的是连续集中的使用内存。这样会出现的情况就是0-1000号这样的低编号Cache Line由于内存经常被分配并使用，而16000号以上的Cache Line由于内存鲜有进程访问，几乎一直处于空闲状态。这种情况下，本来就宝贵的1M二级CPU缓存，使用率也许50%都无法达到。

#### 什么是N-Way Set Associative

** 为什么N-Way Set Associative的Set段是从低位而不是高位开始的 **

下面是一段从[How Misaligning Data Can Increase Performance 12x by Reducing Cache Misses](http://danluu.com/3c-conflict/#fn3)摘录的解释：

> The vast majority of accesses are close together, so moving the set index bits upwards would cause more conflict misses. You might be able to get away with a hash function that isn’t simply the least significant bits, but most proposed schemes hurt about as much as they help while adding extra complexity.

由于内存的访问通常是大片连续的，或者是因为在同一程序中而导致地址接近的（即这些内存地址的高位都是一样的）。所以如果把内存地址的高位作为set index的话，那么短时间的大量内存访问都会因为set index相同而落在同一个set index中，从而导致cache conflicts使得L2, L3 Cache的命中率低下，影响程序的整体执行效率。


### N-Way Set Associative会存在的问题

{% highlight python %}
{% raw %}
>>> data_set = pd.read_csv("./result.csv",names=['bytes','time'])
>>> ggplot(data_set[:30], aes(x='bytes',y='time')) + geom_line() + ylab('Total Time(ms)') + xlab('Data Size(Bytes)')
{% endraw %}
{% endhighlight %}

想要知道更多关于内存地址对齐在目前的这种CPU-Cache的架构下会出现的问题可以详细阅读以下两篇文章：

- [How Misaligning Data Can Increase Performance 12x by Reducing Cache Misses](http://danluu.com/3c-conflict/)
- [Gallery of Processor Cache Effects](http://igoro.com/archive/gallery-of-processor-cache-effects/)

## Cache淘汰策略

常见的淘汰策略主要有`LRU`和`Random`两种。通常意义下LRU对于Cache的命中率会比Random更好，所以CPU Cache的淘汰策略选择的是`LRU`。当然也有些实验显示[在Cache Size较大的时候Random策略会有更高的命中率](http://danluu.com/2choices-eviction/)



1. [Gallery of Processor Cache Effects](http://igoro.com/archive/gallery-of-processor-cache-effects/)
2. [How Misaligning Data Can Increase Performance 12x by Reducing Cache Misses](http://danluu.com/3c-conflict/)   
3. [Introduction to Caches](http://www.cs.umd.edu/class/sum2003/cmsc311/Notes/Memory/introCache.html)
