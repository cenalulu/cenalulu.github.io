---
layout: article
title: "NUMA and MySQL"
modified:
categories: 
#excerpt:
#tags: []
#image:
#    feature: /teaser/xxx
#    teaser: /teaser/xxx
#    thumb:
date: 2015-03-19T14:54:18+08:00
---



> 文章欢迎转载，但转载时请保留本段文字，并置于文章的顶部
> 作者：卢钧轶(cenalulu)
> 本文原文地址：<http://cenalulu.github.io{{ page.url }}>


借用两张 [Carrefour性能测试](address) 的结果图，可以看到几乎所有情况下`interleave`模式下的程序性能都要比默认的亲和模式要高，有时甚至能高达30%。究其根本原因是Linux服务器的大多数workload分布都是随机的：即每个线程在处理各个外部请求对应的逻辑时，所需要访问的内存是在物理上随机分布的。而`interleave`模式就恰恰是针对这种特性将内存page随机打散到各个CPU Core上，使得每个CPU的负载和memory remote access的出现频率都均匀分布。相较NUMA默认的内存分配模式，死板的把内存都优先分配在线程所在Core上的做法，显然普遍适用性要强很多。
![perf1](/images/mysql/numa_mysql/perf1.png)
![perf2](/images/mysql/numa_mysql/perf2.png)

也就是说，像MySQL这种外部请求随机性强，各个线程访问内存在地址上平均分布的这种应用，`interleave`的内存分配模式相较默认模式可以带来一定程度的性能提升。那是不是这样就已经把NUMA的特性和性能发挥到了极致呢？答案是否定的，目前Linux的内存分配机制在NUMA架构的CPU上还有一定的改进空间。
我们来想一下这个情况：MySQL的线程分为两种，用户线程（SQL执行线程）和内部线程（内部功能，如：flush，io，master等）。对于用户线程来说随机性相当的强，但对于内部线程来说他们的行为以及所要访问的内存区域其实是相对固定且可以预测的。如果能对于这把这部分内存集中到这些内存线程所在的core上的时候，就能减少大量`memory remote access`，潜在的提升例如Page Flush，Purge等功能的吞吐量。
既然有可提升空间，那么有没有对应的良药呢？很可惜，这种提升目前只停留在理论和实验阶段。我们来看下难点：要做到按照线程的行为动态的调整page在memore的分布，就势必需要做线程和内存的实时监控（profile）。对于Memory Access这种非常异常频繁的底层操作来说增加profile入口的性能损耗是极大的。在 [关于CPU Cache程序意愿应该知道的那些事]({{ site.url}}/linux/all-about-cpu-cache/)的评论中我也提到过，这个道理和为什么Linux没有全局监控CPU L1/L2 Cache命中率工具的原因是一样的。当然优化不会就此停步。上文提到的`Carrefour`算法和Linux社区的`Auto NUMA patch`都是积极的尝试。什么时候内存profile出现硬件级别，类似于CPU中 [PMU](http://en.wikipedia.org/wiki/VTune) 的功能时，动态内存规划就会展现很大的价值，甚至会作为Linux Kernel的一个内部功能来实现。到那时我们再回过头来做MySQL在NUMA上的调优吧。



- [Percona NUMA aware Configuration](http://www.percona.com/doc/percona-server/5.5/performance/innodb_numa_support.html)
- [Numa system performance issues – more than just swapping to consider](http://www.scalemysql.com/blog/2014/09/05/numa-system-performance-issues-more-than-just-swapping-to-consider/)
- [MySQL Server and NUMA architectures](http://mikaelronstrom.blogspot.com/2010/12/mysql-server-and-numa-architectures.html)
- [Checking /proc/pid/numa_maps can be dangerous for mysql client connections](http://blog.wl0.org/2012/09/checking-procnuma_maps-can-be-dangerous-for-mysql-client-connections/)
- [on swapping and kernels](http://dom.as/2014/01/17/on-swapping-and-kernels/)
