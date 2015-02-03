---
layout: article
title:  "Intel Tick-Tock策略简介"
categories: linux
image:
    teaser: /teaser/tic_tok.png
---

>背景：最近在定位一次硬件升级对数据库性能影响的故障的时候看了挺多Intel的白皮书。其中Intel的tic-toc策略（又称为：tick-tock）很有趣，特别几张roadmap画得很赞。因此摘录在此，已做备忘。


# 什么是tic-toc
---

tic-toc是Intel从2008年引入的一个CPU研发和生产策略。简单的说就是，每一代CPU都会对应tic或者toc。如果这代CPU对应tic，那么这一代CPU相角前一代将会提升制造工艺（即更精细的纳米工艺），例如从22nm到14nm的制造工艺提升。如果这代CPU对应toc，那么这一代CPU将会进行处理器微架构升级，例如支持新功能。

![tic-toc roadmap]({{ site.url }}/images/linux/intel-tic-toc/tic-toc-roadmap.jpg)


# 近几年的tic-toc线路图
---

tic/toc|micro-architecture|fabrification process
----|----|-----
tic|P6/NetBurst|65nm
toc|Core|65nm
tic|Core|45nm
toc|Nehalem|45nm
tic|Nehalem|32nm
toc|Sandy Bridge|32nm
tic|Sandy Bridge|22nm
toc|Haswell|22nm
tic|Haswell|14nm
toc|Skylake|14nm
tic|Skylake|10nm



## Reference

1. [Tick-Tock on wikipidia](http://en.wikipedia.org/wiki/Intel_Tick-Tock)
2. [The Tick-Tock Model Through the Years](http://www.intel.com/content/www/us/en/silicon-innovations/intel-tick-tock-model-general.html)


