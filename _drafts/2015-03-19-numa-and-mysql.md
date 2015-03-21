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

## NUMA的“七宗罪”

几乎所有`重内存操作应用`都会多多少少被NUMA坑害过，让我们看看究竟有多少种在NUMA上栽的方式：

- [MySQL -- The MySQL “swap insanity” problem and the effects of the NUMA architecture](http://blog.jcole.us/2010/09/28/mysql-swap-insanity-and-the-numa-architecture/)
- [PostgreSQL -- PostgreSQL, NUMA and zone reclaim mode on linux](http://frosty-postgres.blogspot.com/2012/08/postgresql-numa-and-zone-reclaim-mode.html)
- [Oracle -- Non-Uniform Memory Access (NUMA) architecture with Oracle database by examples](http://blog.yannickjaquier.com/hpux/non-uniform-memory-access-numa-architecture-with-oracle-database-by-examples.html)
- [Java -- Optimizing Linux Memory Management for Low-latency / High-throughput Databases](http://engineering.linkedin.com/performance/optimizing-linux-memory-management-low-latency-high-throughput-databases)

究其原因几乎都和：“NUMA因为CPU亲和策略导致的内存分配不平均”以及“NUMA Zone内存回收”有关，而和数据库种类并没有直接联系。所以下文我们就拿MySQL为例，来看看重内存操作应用在NUMA架构下到底会出现什么问题。


## MySQL在NUMA架构上会出现的问题

几乎所有`NUMA + MySQL`关键字的搜索结果都会指向：Jeremy Cole大神的两篇文章

- [The MySQL “swap insanity” problem and the effects of the NUMA architecture](http://blog.jcole.us/2010/09/28/mysql-swap-insanity-and-the-numa-architecture/)
- [A brief update on NUMA and MySQL](http://blog.jcole.us/2012/04/16/a-brief-update-on-numa-and-mysql/)

大神解释的非常详尽，有兴趣的读者可以直接看原文。博主这里做一个简单的总结：

- CPU规模因摩尔定律指数级发展，而总线发展缓慢，导致多核CPU通过一条总线共享内存成为瓶颈
- 于是NUMA出现了，CPU平均划分为若干个Chip（不多于4个），每个Chip有自己的内存控制器及内存插槽
- CPU访问自己Chip上所插的内存时速度快，而访问其他CPU所关联的内存（下文称Remote Access）的速度相较慢三倍左右
- 于是Linux内核默认使用CPU亲和的内存分配策略，使内存页尽可能的和调用线程处在同一个Core/Chip中
- 由于内存页没有动态调整策略，使得大部分内存页都集中在`CPU 0`上
- 又因为`Reclaim`策略优先淘汰/Swap本Chip上的内存，使得大量有用内存被换出
- 当被换出页被访问时问题就以数据库响应时间飙高甚至阻塞的形式出现了


## 解决方案

Jeremy Cole大神推荐的三个方案如下，如果想详细了解可以阅读 [原文](http://blog.jcole.us/2012/04/16/a-brief-update-on-numa-and-mysql/)

- `numactl --interleave=all`
- 在MySQL进程启动前，使用`sysctl -q -w vm.drop_caches=3`清空文件缓存所占用的空间
- Innodb在启动时，就完成整个`Innodb_buffer_pool_size`的内存分配

这三个方案也被业界普遍认可可行，同时在 [Twitter 的5.5patch](https://github.com/twitter/mysql/commit/19cf63c596c0146a72583998d138190cc285df5c) 和 [Percona 5.5 Improved NUMA Support](http://www.percona.com/doc/percona-server/5.5/performance/innodb_numa_support.html) 中作为功能被支持。
不过这三合一的解决方案只是减少了NUMA内存分配不均，导致的MySQL SWAP问题出现的可能性。如果当系统上其他进程，或者MySQL本身需要大量内存时，Innodb Buffer Pool的那些Page同样还是会被Swap到存储上。于是又在这基础上出现了另外几个进阶方案

- 配置`vm.zone_reclaim_mode = 0`使得内存不足时`去remote memory分配`优先于`swap out local page`
- `echo -15 > /proc/<pid_of_mysqld>/oom_adj`调低MySQL进程被`OOM_killer`强制Kill的可能
- [memlock](http://dev.mysql.com/doc/refman/5.6/en/server-options.html#option_mysqld_memlock)
- 对MySQL使用Huge Page（黑魔法，巧用了Huge Page不会被swap的特性）


## 重新审视问题

如果本文写到这里就这么结束了，那和搜索引擎结果中大量的科普帖没什么差别。虽然我们用了各种参数调整减少了问题发生概率，那么真的就彻底解决了这个问题么？问题根源究竟是什么？让我们回过头来重新审视下这个问题：


#### NUMA Interleave真的好么？

借用两张 [Carrefour性能测试](address) 的结果图，可以看到几乎所有情况下`interleave`模式下的程序性能都要比默认的亲和模式要高，有时甚至能高达30%。究其根本原因是Linux服务器的大多数workload分布都是随机的：即每个线程在处理各个外部请求对应的逻辑时，所需要访问的内存是在物理上随机分布的。而`interleave`模式就恰恰是针对这种特性将内存page随机打散到各个CPU Core上，使得每个CPU的负载和memory remote access的出现频率都均匀分布。相较NUMA默认的内存分配模式，死板的把内存都优先分配在线程所在Core上的做法，显然普遍适用性要强很多。
![perf1](/images/mysql/numa_mysql/perf1.png)
![perf2](/images/mysql/numa_mysql/perf2.png)

也就是说，像MySQL这种外部请求随机性强，各个线程访问内存在地址上平均分布的这种应用，`interleave`的内存分配模式相较默认模式可以带来一定程度的性能提升。那是不是这样就已经把NUMA的特性和性能发挥到了极致呢？答案是否定的，目前Linux的内存分配机制在NUMA架构的CPU上还有一定的改进空间。
我们来想一下这个情况：MySQL的线程分为两种，用户线程（SQL执行线程）和内部线程（内部功能，如：flush，io，master等）。对于用户线程来说随机性相当的强，但对于内部线程来说他们的行为以及所要访问的内存区域其实是相对固定且可以预测的。如果能对于这把这部分内存集中到这些内存线程所在的core上的时候，就能减少大量`memory remote access`，潜在的提升例如Page Flush，Purge等功能的吞吐量，甚至可以提高MySQL Crash后Recovery的速度（由于recovery是单线程）。
既然有可提升空间，那么有没有对应的良药呢？很可惜，这种提升目前只停留在理论和实验阶段。我们来看下难点：要做到按照线程的行为动态的调整page在memore的分布，就势必需要做线程和内存的实时监控（profile）。对于Memory Access这种非常异常频繁的底层操作来说增加profile入口的性能损耗是极大的。在 [关于CPU Cache程序意愿应该知道的那些事]({{ site.url}}/linux/all-about-cpu-cache/)的评论中我也提到过，这个道理和为什么Linux没有全局监控CPU L1/L2 Cache命中率工具的原因是一样的。当然优化不会就此停步。上文提到的`Carrefour`算法和Linux社区的`Auto NUMA patch`都是积极的尝试。什么时候内存profile出现硬件级别，类似于CPU中 [PMU](http://en.wikipedia.org/wiki/VTune) 的功能时，动态内存规划就会展现很大的价值，甚至会作为Linux Kernel的一个内部功能来实现。到那时我们再回过头来做MySQL在NUMA上的调优吧。

#### 究竟是哪里出了问题

**NUMA的问题？**
NUMA本身没有错，是CPU发展的一种必然趋势。但是NUMA的出现使得操作系统不得不关注内存访问速度不平均的问题。

**Linux Kenel内存分配策略的问题？**
分配策略的初衷是好的，为了内存更接近需要他的线程，但是没有考虑到数据库这种大规模内存使用的应用场景。同时缺乏动态调整的功能，使得这种悲剧在内存分配的那一刻就被买下了伏笔。

**数据库设计者不懂NUMA？**
数据库设计者也许从一开始就不会意识到NUMA的流行，或者甚至说提供一个透明稳定的内存访问是操作系统最基本的职责。那么在现状改变非常困难的情况下（下文会提到为什么困难）是不是作为内存使用者有义务更好的去理解使用NUMA？




- [Percona NUMA aware Configuration](http://www.percona.com/doc/percona-server/5.5/performance/innodb_numa_support.html)
- [Numa system performance issues – more than just swapping to consider](http://www.scalemysql.com/blog/2014/09/05/numa-system-performance-issues-more-than-just-swapping-to-consider/)
- [MySQL Server and NUMA architectures](http://mikaelronstrom.blogspot.com/2010/12/mysql-server-and-numa-architectures.html)
- [Checking /proc/pid/numa_maps can be dangerous for mysql client connections](http://blog.wl0.org/2012/09/checking-procnuma_maps-can-be-dangerous-for-mysql-client-connections/)
- [on swapping and kernels](http://dom.as/2014/01/17/on-swapping-and-kernels/)
- [Optimizing Linux Memory Management for Low-latency / High-throughput Databases](http://engineering.linkedin.com/performance/optimizing-linux-memory-management-low-latency-high-throughput-databases)
