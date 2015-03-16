---
layout: article
title:  "为什么数组标号是从0开始的"
categories: linux
toc: true
ads: true
image:
    teaser: /teaser/from_zero.jpg
---


> 本文通过汇总一些网上搜集到的资料，总结出大部分编程语言中数组下标从0开始的原因


---


## 背景

我们知道大部分编程语言中的数组都是从0开始编号的，即`array[0]`是数组的第一个元素。这个和我们平时生活中从1开始编号的习惯相比显得很反人类。那么究竟是什么样的原因让大部分编程语言数组都遵从了这个神奇的习惯呢？本文最初是受[stackoverflow上的一个问题](http://stackoverflow.com/questions/7320686/why-does-the-indexing-start-with-zero-in-c)的启发，通过搜集和阅读了一些资料在这里做个总结。当然，本文摘录较多的过程结论，如果你想把这篇文章当做快餐享用的话，可以直接跳到文章末尾看结论。


---


## 最早的原因

在回答大部分我们无法解释的诡异问题时，我们最常用的辩词通常是`历史原因`。那么，历史又是出于什么原因，使用了0标号数组呢？[Mike Hoye]()就是本着这么一种追根刨地的科学精神为我们[找到了解答](http://exple.tive.org/blarg/2013/10/22/citation-needed/)。以下是一些他的重要结论的摘录翻译：

据作者的说法，C语言中从0开始标号的做法是沿用了BCPL这门编程语言的做法。而BCPL中如果一个变量是指针的话，那么该指针可以指向一系列连续的相同类型的数值。那么`p+0`就代表了这一串数值的第一个。在BCPL中数组第5个元素的写法是`p!5`，而C语言中把写法改成了`p[5]`，也就是现在的数组。具体原文摘录如下：

> If a BCPL variable represents a pointer, it points to one or more consecutive words of memory. These words are the same size as BCPL variables. Just as machine code allows address arithmetic so does BCPL, so if p is a pointer p+1 is a pointer to the next word after the one p points to. Naturally p+0 has the same value as p. The monodic indirection operator ! takes a pointer as it’s argument and returns the contents of the word pointed to. If v is a pointer !(v+I) will access the word pointed to by v+I.

至于为什么C语言中为什么使用`[]`方括号来表示数组下标，这个设计也有一定来历。据C语言作者的说法是方括号是现代键盘上唯一较为容易输入的成对符号（不用`shift`）不信你对着键盘找找？



--- 


## 为什么这个反人类设计在一段时间内一直没有被改变

根据Mike的说法，BCPL是被设计在IBM硬件环境下编译运行的。在1960后的很长一段时间内，服务器硬件几乎被IBM统治。一个城市内也许至于一台超级计算机，还需要根据时间配额使用。当你当天的配额用完以后，你的程序就被完全清出计算队列。甚至连计算结果都不给你保留，死无全尸。这个时候写一段高效的程序，就显得比什么都重要了。而这时0下标数组又体现了出了它的另一个优势，就是：相较于1下标数组，它的编译效率更高。原文摘录如下：

> So: the technical reason we started counting arrays at zero is that in the mid-1960’s, you could shave a few cycles off of a program’s compilation time on an IBM 7094. The social reason is that we had to save every cycle we could, because if the job didn’t finish fast it might not finish at all and you never know when you’re getting bumped off the hardware because the President of IBM just called and fuck your thesis, it’s yacht-racing time.

此外，还有另外一种说法。在C语言中有指针的概念，而指针数组标号实际上是一个偏移量而不是计数作用。例如对于指针`p`，第N个元素是`*(p+N)`，指针指向数组的第一个元素就是`*(p+0)`，


---


## 一些现代语言为什么仍然使用这种做法

上文中提到的为了计较分秒的编译时间而使用0下标数组，在硬件飞速发展的今天显然是不必要的。那么为什么一些新兴语言，如Python依然选择以0作为数组第一个元素呢？难道也是`历史原因`？对于这个问题，Python的作者Guido van Rossum也有[自己的答案](https://plus.google.com/115212051037621986145/posts/YTUxbXYZyfi)。这里大致概括一下作者的用意：从0开始的半开放数组写法在表示子数组（或者子串）的时候格外的便捷。例如：`a[0:n]`表示了a中前n个元素组成的新数组。如果我们使用1开始的数组写法，那么就要写成`a[1:n+1]`。这样就显得不是很优雅。那么问题来了，Python数组为什么使用半开放，即`[m,n)`左闭合右开发的写法呢？这个理解起来就比较简单，读者可以参考[http://www.cs.utexas.edu/users/EWD/ewd08xx/EWD831.PDF](http://www.cs.utexas.edu/users/EWD/ewd08xx/EWD831.PDF)作为扩展阅读。下面摘录一段Python作者的原话：

> Using 0-based indexing, half-open intervals, and suitable defaults (as Python ended up having), they are beautiful: `a[:n]` and `a[i:i+n]`; the former is long for `a[0:n]`.
> Using 1-based indexing, if you want `a[:n]` to mean the first n elements, you either have to use closed intervals or you can use a slice notation that uses start and length as the slice parameters. Using half-open intervals just isn't very elegant when combined with 1-based indexing. Using closed intervals, you'd have to write `a[i:i+n-1]` for the n items starting at i. So perhaps using the slice length would be more elegant with 1-based indexing? Then you could write `a[i:n]`. And this is in fact what ABC did -- it used a different notation so you could write `a@i|n`.(See http://homepages.cwi.nl/~steven/abc/qr.html#EXPRESSIONS.)


---


## 总结

从0标号的数组传统，沿用了这么长时间的原因主要列举如下：

- 在计算资源缺乏的过去，0标号的写法可以节省编译时间
- 现代语言中0标号可以更优雅的表示数组字串
- 在支持指针的语言中，标号被视作是偏移量，因此从0开始更符合逻辑


---


### 参考文献

1. (http://developeronline.blogspot.com/2008/04/why-array-index-should-start-from-0.html)
2. [http://exple.tive.org/blarg/2013/10/22/citation-needed/]
3. [https://plus.google.com/115212051037621986145/posts/YTUxbXYZyfi]
4. [http://stackoverflow.com/questions/7320686/why-does-the-indexing-start-with-zero-in-c]








