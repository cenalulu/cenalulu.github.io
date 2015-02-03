---
layout: article
title:  "Project Euler第一阶段刷题总结"
categories: python
toc: true
ads: true
image:
    teaser: /teaser/euler.png
---

> 本文是博主对于用Python进行Project Euler第一阶段刷题的总结和一些感悟

> 背景：为了更好的学习Python，博主从2015-01-01开始进行Project Euler的刷题。至今已经完成了两个阶段（50题）。下面是两阶段以来的一些经验和感悟


---

## Project Euler是什么

可能读者还没有听说过或者亲身接触过[Project Euler](https://projecteuler.net/)。Project Euler实际是一个在线的编程题库，并附带答案批改功能。目前一共有500+的题目，每道题目都有一个唯一的数字答案。答题者通过阅读题目并通过编程的方式得到最后的答案（一般题目的计算量较大，基本只能通过编程得到答案），然后将得到的数字答案提交到网站上进行批改。和Project Euler类似的在线编程挑战网站还有很多，博主之前也转译过 [一个比较详尽的列表]({{ site.url }}/python/online-programming-test/)
下面是具体的答题界面截图：
![img]({{ site.url }}/images/python/euler/problem.png)




## 一些感悟

以下是一些博主在刷完第一阶段（50题）后的感悟，希望能对将要刷或者正在刷的编程爱好者们提供一些决策的信息：

- 第一阶段题目几乎全与数论相关
- 素数的生成及判断给定自然数是否是素数的题目占到较大比重
- 考察到的编程知识点主要有：
    - 循环
    - 递归
    - 字符串和数字的相互转换
- 完全不使用任何类库都可以完成解题
- 使用素数相关的库也可以帮助简化解题

除了以上谈到的一些特点外，总体来说Project Euler属于一个入门级的编程题库。基本符合他的宗旨：帮助那些主修计算机相关学科，且有余力的同学获得更多的实际锻炼。如果你是一个有一些经历的从业人员，若非处于一些特殊的兴趣爱好（纯刷题，拿虚拟徽章等）还是不建议把时间浪费在Project Euler上。可以从[其他在线编程挑战网站]({{ site.url }}/python/online-programming-test/)中寻找突破。而博主刷Project Euler的目的也比较单纯：从0开始学习Python。所以，如果你正准备开始尝试学习一门新的程序语言时，Project Euler绝对是一个不错的选择。花2-3周时间刷完50题你就能掌握语言的基本语法和类库了。


---


## 关于素数生成

Project Euler中有较大一部分题目中需要用到素数生成和素数检验。甚至Project还特地设立了一个[Prime Obsession](https://projecteuler.net/award=15)的里程碑，可见素数对于解题的重要性。第一阶段中博主尝试使用自己的代码进行素数生成。还特别对自己的素数生成Module[做了优化]({{ site.url }}/python/pythonic-way-of-prime-generator)。随着题目难度和计算量的增加，基于简单数论的素数生成优化已经满足不了coding需求了（NlogN的复杂度已经跟不上节奏）。因此，博主开始尝试使用`pyprimes`类库解题，这个在下面的章节也会提到。当然，如果读者有兴趣的话，也可以根据对于一些数论知识的理解去做自己的Python实现。下面是一些关于如何快速生成素数和快速检查素数的一些知识分享：


---


## 常用Module

最初博主刷题的目标是不使用任何一个Python附带的Module，甚至是基本Module也不使用。如果有重复代码的发生，都尝试写成自己的library。DIY everything。但随着题目概念的复杂和解题难度的增加，再去做一些基础库的重复造轮效率上有明显的降低。因此从Problem 23开始，博主就引入了一些Python的官方或者第三方Module，以便能把精力集中在题目本身的重点上。以下是前两阶段刷题中经常用到的Module，方便大家参考和自己备忘：

- pyprimes （用于素数生成和素数检查）
    - isprime
    - prime_below
- itertools （用于序列生成和排列组合的生成）
    - count
    - permutation
    - combination
