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

#### 为什么Cache Line的大小事64Bytes

#### 为什么Cache不能做成Fully Associative

Fully Associative 字面意思是全关联。在CPU Cache中的含义是：如果在一个Cache集内，任何一个内存地址的数据可以被缓存在任何一个Cache Line里，那么我们成这个cache是Fully Associative。从定义中我们可以得出这样的结论：给到一个内存地址，要知道他是否存在于Cache中，需要遍历所有Cache Line并比较缓存内容的内存地址。而Cache的本意就是为了在尽可能少得CPU Cycle内取到数据。那么想要设计一个快速的Fully Associative的Cache几乎是不可能的。

#### 为什么Cache不能做成Direct Mapped

和Fully Associative完全相反，使用Direct Mapped模式的Cache给定一个内存地址，就唯一确定了一条Cache Line。设计复杂度低且速度快。那么为什么Cache不使用这种模式呢？让我们来想象这么一种情况：一个拥有1M L2 Cache的32位CPU，每条Cache Line的大小为64Bytes。那么整个L2Cache被划为了`1M/64=16384`条Cache Line。我们为每条Cache Line从0开始编上号。同时64位CPU所能管理的内存地址范围是`2^32=4G`，那么Direct Mapped模式下，内存也被划为`4G/16384=256K`的小份。也就是说每256K的内存地址共享一条Cache Line。但是，这种模式下每条Cache Line的使用率如果要做到接近100%，就需要操作系统对于内存的分配和访问在地址上也是近乎平均的。而与我们的意愿相反，为了减少内存碎片和实现便捷，操作系统更多的是连续集中的使用内存。这样会出现的情况就是0-1000号这样的低编号Cache Line由于内存经常被分配并使用，而16000号以上的Cache Line由于内存鲜有进程访问，几乎一直处于空闲状态。这种情况下，本来就宝贵的1M二级CPU缓存，使用率也许50%都无法达到。

#### 什么是N-Way Set Associative


### N-Way Set Associative会存在的问题




1. [Gallery of Processor Cache Effects](http://igoro.com/archive/gallery-of-processor-cache-effects/)
2. [How Misaligning Data Can Increase Performance 12x by Reducing Cache Misses](http://danluu.com/3c-conflict/)   
3. [Introduction to Caches](http://www.cs.umd.edu/class/sum2003/cmsc311/Notes/Memory/introCache.html)
