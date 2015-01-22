---
layout: article
title:  "Project Euler第一阶段刷题总结"
categories: python
toc: true
ads: true
#image:
#    teaser: /teaser/default.jpg
---

> 本文是博主对于用Python进行Project Euler第一阶段刷题的总结和一些感悟

> 背景：为了更好的学习Python，博主从2015-01-01开始进行Project Euler的刷题。至今已经完成了两个阶段（50题）。下面是两阶段以来的一些经验和感悟


---


## 一些感悟




## 关于素数生成

Project Euler中有较大一部分题目中需要用到素数生成和素数检验。甚至Project还特地设立了一个[Prime Obsession](https://projecteuler.net/award=15)的里程碑，可见素数对于解题的重要性。第一阶段中博主尝试使用自己的代码进行素数生成。还特别对自己的素数生成Module[做了优化]({{ site.url }}/python/pythonic-way-of-prime-generator)。随着题目难度和计算量的增加，基于简单数论的素数生成优化已经满足不了coding需求了（NlogN的复杂度已经跟不上节奏）。因此，博主开始尝试使用`pyprimes`类库解题，这个再下面的章节也会提到。当然，如果读者有兴趣的话，也可以根据对于一些数论知识的理解去做自己的Python实现。下面是一些关于如何快速生成素数和快速检查素数的一些知识分享：




---


## 常用Module

最初博主刷题的目标是不使用任何一个Python附带的Module，甚至是基本Module也不使用。如果有重复代码的发生，都尝试写成自己的library。DIY everything。但随着题目概念的复杂和解题难度的增加，再去做一些基础库的重复造轮效率上有明显的降低。因此从Problem 23开始，博主就引入了一些Python的官方或者第三方Module，以便能把精力集中在题目本身的重点上。以下是前两阶段刷题中经常用到的Module，方便大家参考和自己备忘：

- pyprimes （用于素数生成和素数检查）
    - isprime
- itertools （用于序列生成和排列组合的生成）
    - count
    - permutation
    - combination
