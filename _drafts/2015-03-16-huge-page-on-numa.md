---
layout: article
title: "Huge Page 是否是拯救性能的万能良药？"
modified:
categories: linux
#excerpt:
tags: [huge page, big page, numa]
image:
#    feature: /teaser/xxx
    teaser: /teaser/huge_page.jpg
#    thumb:
date: 2015-03-16T22:17:50+08:00
---


> 本文将分析是否Huge Page在任何条件下（特别是NUMA架构下）都能带来性能提升。

> 文章欢迎转载，但转载时请保留本段文字，并置于文章的顶部
> 作者：卢钧轶(cenalulu)
> 本文原文地址：<http://cenalulu.github.io{{ page.url }}>


--- 


## 关于Huge Page

在正式开始本文分析前，我们先大概介绍下Huge Page和使用场景。如果读者还不太熟悉CPU Cache的话建议阅读博主之前的 [关于CPU Cache -- 程序猿需要知道的那些事](http://cenalulu.github.io/linux/all-about-cpu-cache/)。
**为什么需要Huge Page**
了解CPU Cache大致架构的话，一定听过TLB Cache。`Linux`系统中程序的汇编指令都使用的是`Virtual Address`即每个程序的内存地址都是从0开始的。而实际的数据访问是要通过`Physical Address`进行的。因此，每次内存操作，CPU都需要从`page table`中把`Virtual Address`翻译成对应的`Physical Address`，那么对于大量内存密集型程序来说`page table`的查找就会成为程序的瓶颈。所以就出现了TLB(Translation Lookaside Buffer) Cache，但又由于TLB是最基础的Cache，所以他的响应时间需求极高，需要在几个CPU Cycle级别，那么制造成本和工艺的限制，TLB Cache的容量就非常小在几十到几百的级别。我们来算下按照标准的Linux页大小(page size) 4K，一个能缓存64元素的TLB Cache只能涵盖`4K*64 = 256K`的热点数据的内存地址，显然是离理想非常遥远的。于是Huge Page就产生了。

![tlb_lookup](/images/linux/huge_page/tlb_lookup.png)

**什么是Huge Page**
既然TLB Cache的容量是受制造工艺限制的硬伤无法改变，那么只能从系统层面增加一个TLB entry所能对应的物理内存大小，从而增加TLB Cache所能涵盖的热点数据量。假设我们把Linux `Page Size`增加到`16M`，那么一个64元素的TLB Cache就能顾及`64*16M = 1G`的内存热点数据，这样的大小相较上文的`256K`就显得非常理想了。像这种将`Page Size`加大的技术就是`Huge Page`。


--- 


## Huge Page是万能的？

了解了Huge Page的由来和原理后，我们不难总结出能从Huge Page受益的程序必然是那些热点数据分散且至少超过64个4K Page Size的程序。此外，如果程序的主要运行时间并不是消耗在TLB Cache Miss后的Page Table Lookup上，那么TLB再怎么大，Page Size再怎么增加都是徒劳。在[LWN的一篇入门介绍](http://lwn.net/Articles/379748/)中就提到了这个原理，并且给出了比较详细的估算方法。简单的说就是：先通过`oprofile`抓取到`TLB Miss`导致的运行时间占程序总运行时间的多少，来计算出Huge Page所能带来的预期性能提升。
除了这些基础的条件，常常被人们忽略的一种情况就是在目前常见的NUMA体系下Huge Page也并非万能钥匙，使用不当甚至会使得程序或者数据库性能下降10%。而这也是下文将重点分析的一个方面


--- 


## Huge Page on NUMA

[Large Pages May Be Harmful on NUMA Systems](https://www.usenix.org/conference/atc14/technical-sessions/presentation/gaud)一文的作者曾今做过一个实验，测试Huge Page在NUMA环境的各种不同应用场景下带来的性能差异。从下图可以看到Huge Page对于相当一部分的应用场景并不能很好的提升性能，甚至会带来高达10%的性能损耗。
<img src="/images/linux/huge_page/perf_test.png" style="max-width:80%" />

性能下降的原因主要有以下两点

### CPU对同一个Page抢占增多

对于写操作密集型的应用，Huge Page会大大增加Cache写冲突的发生概率。由于CPU独立Cache部分的写一致性用的是`MESI协议`，写冲突就意味：

- 通过CPU间的总线进行通讯，造成总线繁忙
- 同时也降低了CPU执行效率。
- CPU本地Cache频繁失效

类比到数据库就相当于，原来一把用来保护10行数据的锁，现在用来锁1000行数据了。必然这把锁在线程之间的争抢概率要大大增加。


### 连续数据需要跨CPU读取

从下图我们可以看到，原本在4K小页上可以连续分配，并因为较高命中率而在同一个CPU上实现locality的数据。到了Huge Page的情况下，就有一部分数据为了填充统一程序中上次内存分配留下的空间，而被迫分布在了两个页上。而在所在Huge Page中占比较小的那部分数据，由于在计算CPU亲和力的时候权重小，自然就被附着到了其他CPU上。那么就会造成：本该以热点形式存在于CPU2 L1或者L2 Cache上的数据，不得不通过CPU inter-connect去remote CPU获取数据。

>  delays re-sulting from traversing a greater physical distance to reach a remote node, are not the most important source of performance overhead. On the other hand, congestion on interconnect links and in memory controllers, which results from high volume of data flowing across the system, can dramatically hurt performance. 

> Under interleaving, the memory latency re- duces by a factor of 2.48 for Streamcluster and 1.39 for PCA. This effect is entirely responsible for performance improvement under the better policy. The question is, what is responsible for memory latency improvements? It turns out that interleaving dramatically reduces memory controller and interconnect congestion by allevi- ating the load imbalance and mitigating traffic hotspots.







Reference:

- [Huge pages part 5: A deeper look at TLBs and costs](http://lwn.net/Articles/379748/)
- [About Huge Page](https://www.kernel.org/doc/Documentation/vm/hugetlbpage.txt)
- [TLB on Wikipedia](http://en.wikipedia.org/wiki/Translation_lookaside_buffer)
- [Traffic Management: A Holistic Approach to Memory Placement on NUMA Systems](https://www.cs.sfu.ca/~fedorova/papers/asplos284-dashti.pdf)
