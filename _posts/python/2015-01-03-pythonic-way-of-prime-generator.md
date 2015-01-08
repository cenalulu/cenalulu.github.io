---
layout: article
title:  "记录一段生成素数python代码的调优过程"
date:   2014-12-29 01:53:43
categories: python
---

> 简介：本文主要记录了博主对一段使用python实现的素数生成代码的不断优化过程。


> 背景：最近在刷[Project Euler](https://projecteuler.net)的题目，刷到[第十题](https://projecteuler.net/problem=10)（计算2百万以下素数的和）的时候发现之前的素数生成代码效率太低导致几分钟都出不来。于是通过不断的调优，终于得到一个能在秒级算出2百万以内的素数的generator。
本文的调优过程基本不涉及基于数论的调优，如果您希望得到一个拥有极致性能的python素数生成代码，可以使用[pyprimes](https://pypi.python.org/pypi/pyprimes)


# 第一版
---

素数也即：无法被除了1和本身以外的任何自然数整除的自然数。因此第一版的程序实现起来也格外的直白。把从`2`开始到`数值本身-1`范围内的自然数都去除一下待判断的数就能得到结论了。于是就有了第一版程序如下：

~~~ python
class Prime:
    def __init__(self):
        self.prime_list = []
        self.v = 3
    def get_prime(self):
	yield 2
        while True:
            for i in range(2, self.v):
                if self.v % i == 0:
                    break
            else:
                self.prime_list.append(self.v)
                yield self.v
            self.v += 1
~~~

# 第二版
---

当然这段代码对于小的素数是可以work的。单当使用这段代码调试[Euler第三题](https://projecteuler.net/problem=10)的时候就会发现在判断大数是否是素数时耗时很久。判断一个数是否是素数的时间复杂度目前是`O(N^2)`。于是就想到需要通过减少判断次数来达到提升代码效率的方法。最容易想到的一种方法是：大于被判断值的平方根的数，无需再去判断是否可以整除被判断数了。现在单个素数的判断时间复杂度优化到`O(logN)`

					
~~~ python
class Prime:
    def __init__(self):
        self.prime_list = [2]
        self.v = 3
    def get_prime(self):
        yield 2
        while True:
            for i in (3, self.v):
                if self.v % i == 0:
                    break
                elif i * i > self.v + 1:
                    yield self.v
                    self.prime_list.append(self.v)
                    break
            else:
                self.prime_list.append(self.v)
                yield self.v
            self.v += 1
~~~


# 第三版
---

当然这还远远不够，接踵而来的是第7题(找到第1000个素数）。寻找第N个素数的命题大大放大了我们时间复杂度。目前程序的时间复杂度是`O(NlogN)`。于是再次寻找是否还有其他可以跳过的检查项。我们可以发现所有偶数其实是可以完全可以跳过不判断的。但是判断偶数本身也是一次计算操作，所以简单的通过`if self.v % 2 == 0 `来跳过一次检查并不能带来很大的性能提升，所以这里用了一个比较tricky方式跳过偶数：由于序列是从3开始检查，因此把增长步进调整为2，那么就自然跳过了所有偶数

~~~ python
class Prime:
    def __init__(self):
        self.prime_list = []
        self.v = 3
    def get_prime(self):
	yield 2
        while True:
            for i in self.prime_list:
                if self.v % i == 0:
                    break
            else:
                self.prime_list.append(self.v)
                yield self.v
            self.v += 2
~~~
这部分优化后，找到第N个素数的时间比原来少了一半。


# 第四版(最终版)
---

实际运行后发现即使时间相较之前少了一半，但总体运行时间仍然不理想(十几秒级别)。冥想。。。过后又有一个大招：由于所有合数都能写成素数相乘，因此如果能够被某个合数整除，也必然能被某个素数整除。那么我们的所有除数只需从被判断的数小的素数集合中选择即可。于是得到以下优化代码

~~~ python
class Prime:
    def __init__(self):
        self.prime_list = [2]
        self.v = 3
    def get_prime(self):
        yield 2
        while True:
            for i in self.prime_list:
                if self.v % i == 0:
                    break
                elif i * i > self.v + 1:
                    yield self.v
                    self.prime_list.append(self.v)
                    break
            else:
                self.prime_list.append(self.v)
                yield self.v
            self.v += 2
~~~
这部分优化后，找到第N个素数的时间从`O(N/2logN)`变成了`O((logN)^2)`


