---
layout: article
title: "MESI"
modified:
categories: linux   
#excerpt:
tags: [MESI, cache coherence]
image:
#    feature: /teaser/facebook_feature.jpg
    teaser: /teaser/cpu_cache.jpg
#  thumb:
date: 2015-03-02T21:23:55+08:00
---

> 本文总结了多核CPU缓存一致性问题的基本知识，以及MESI的发展过程

> 在阅读[What Every Programmer Should Know About Memory ](http://www.akkadia.org/drepper/cpumemory.pdf)时，文中用较大篇幅提到了MESI模型。这部分看的是云里雾里。为了更好地理解这个模型，博主做了一定的资料收集和梳理。从缓存一致性问题的起源开始，逐步理解MESI模型的发展过程。这篇博文也是对整个理解过程的一个总结

## Cache Coherence

我们先摘录一段wikipedia上[关于Cache Coherence的描述](http://en.wikipedia.org/wiki/Cache_coherence)来引出缓存一致性出现的原因

> In a shared memory multiprocessor system with a separate cache memory for each processor, it is possible to have many copies of any one instruction operand: one copy in the main memory and one in each cache memory. When one copy of an operand is changed, the other copies of the operand must be changed also. Cache coherence is the discipline that ensures that changes in the values of shared operands are propagated throughout the system in a timely fashion

从引用描述可以看出，缓存一致性问题是由于多核CPU（或者是拥有独立缓存的超线程单核CPU）的出现而随之产生的。现代多核CPU的每个core都会有自己独立的cache，一般是`L1 Cache`。一个简单的结构如下图
![shared_memory](/images/linux/cpu_cache/shared_memory.jpg)
那么当某个core更新一个memory address上的数据时，就会出现两个core同时在自己的cache中维护了一个不同版本数据的情况。这时数据就产生的冲突，一致性也就无法保障了。Cache Coherence也就是为了解决这个问题而产生的定义。下面我们就来看下缓存一致性的具体定义：

- 一个Core在一次写入和读取操作之间如没有夹杂着其他Core的写入操作，那么他应该读到的是刚执行的写入操作的结果。In a read made by a processor P to a location X that follows a write by the same processor P to X, with no writes of X by another processor occurring between the write and the read instructions made by P, X must always return the value written by P. This condition is related with the program order preservation, and this must be achieved even in monoprocessed architectures.
- 一个Core在其他Core的写入操作后应该能够立即读到新写入的数据。A read made by a processor P1 to location X that happens after a write by another processor P2 to X must return the written value made by P2 if no other writes to X made by any processor occur between the two accesses and the read and write are sufficiently separated. This condition defines the concept of coherent view of memory. If processors can read the same old value after the write made by P2, we can say that the memory is incoherent.
- 同一内存的地址的写入操作必须是顺序执行的。Writes to the same location must be sequenced. In other words, if location X received two different values A and B, in this order, from any two processors, the processors can never read location X as B and then read it as A. The location X must be seen with values A and B in that order.


---


## Coherency mechanisms

保证缓存一致性的方法一般有以下三种：

#### Directory-based
In a directory-based system, the data being shared is placed in a common directory that maintains the coherence between caches. The directory acts as a filter through which the processor must ask permission to load an entry from the primary memory to its cache. When an entry is changed, the directory either updates or invalidates the other caches with that entry.

#### Snooping
First introduced in 1983, snooping is a process where the individual caches monitor address lines for accesses to memory locations that they have cached. It is called a write invalidate protocol when a write operation is observed to a location that a cache has a copy of and the cache controller invalidates its own copy of the snooped memory location.

#### Snarfing
It is a mechanism where a cache controller watches both address and data in an attempt to update its own copy of a memory location when a second master modifies a location in main memory. When a write operation is observed to a location that a cache has a copy of, the cache controller updates its own copy of the snarfed memory location with the new data.





## Coherence Protocol


现代CPU的缓存一致性协议大多是根据更宽松的一致性模型来设计的，即不完全符合顺序一致性模型。有点类似于关系型数据库中的事务四个的隔离级别之间的关系。`sequential consistency`类比与`Serializable`，约束最严格但是实现的性能代价也最大。因此，一般都会退其次，在满足大部分一致性要求的同时，保证一定的性能。所以也就有了`weak consistency model`和`release consistency model`
下面是从wikipedia摘录的一段关于Cache Coherence Protocol的描述：

> A coherency protocol is a protocol that maintains the consistency between all the caches in a system of distributed shared memory. The protocol maintains memory coherence according to a *specific consistency model*; 
> older multiprocessors support the sequential consistency model, while modern shared memory systems typically support the release consistency or weak consistency models.





