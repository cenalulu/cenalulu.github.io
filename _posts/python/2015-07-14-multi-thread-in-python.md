---
layout: article
title: "Python多线程的正确姿势"
modified:
categories: python
#excerpt:
#tags: []
#image:
#    feature: /teaser/xxx
#    teaser: /teaser/xxx
#    thumb:
date: 2015-07-14T23:01:57+01:00
---



> 文章欢迎转载，但转载时请保留本段文字，并置于文章的顶部
> 作者：卢钧轶(cenalulu)
> 本文原文地址：<http://cenalulu.github.io{{ page.url }}>


## 前言

假设你是一个python初学者，想要通过python实现一个带有并发控制的多线程/进程程序，又感觉无从下手时，想必会第一时间求助于google/baidu。但你会发现，排序最高的答案都是：[这样](http://www.runoob.com/python/python-multithreading.html)或者[那样](http://python.jobbole.com/58700/)已经过时的方法。博主写此文的目的也是为了让初学者少走弯路，能从本文了解到过去方法的一些缺陷，以及目前版本下python多线程的推荐使用方式。


## 过时的方法： Threading + Queue

这个是网络上历史最悠久，也是流传最为广泛的教程之一。该方案可以说是完全 `build a thread pool from scratch`。我们下面来看下它的具体实现。

{% highlight python %}
#coding=utf-8
#!/usr/bin/python

import Queue
import threading
import time

exitFlag = 0

class myThread (threading.Thread):
    def __init__(self, threadID, name, q):
        threading.Thread.__init__(self)
        self.threadID = threadID
        self.name = name
        self.q = q
    def run(self):
        print "Starting " + self.name
        process_data(self.name, self.q)
        print "Exiting " + self.name

def process_data(threadName, q):
    while not exitFlag:
        queueLock.acquire()
        if not workQueue.empty():
            data = q.get()
            queueLock.release()
            print "%s processing %s" % (threadName, data)
        else:
            queueLock.release()
        time.sleep(1)

threadList = ["Thread-1", "Thread-2", "Thread-3"]
nameList = ["One", "Two", "Three", "Four", "Five"]
queueLock = threading.Lock()
workQueue = Queue.Queue(10)
threads = []
threadID = 1

# 创建新线程
for tName in threadList:
    thread = myThread(threadID, tName, workQueue)
    thread.start()
    threads.append(thread)
    threadID += 1

# 填充队列
queueLock.acquire()
for word in nameList:
    workQueue.put(word)
queueLock.release()

# 等待队列清空
while not workQueue.empty():
    pass

# 通知线程是时候退出
exitFlag = 1

# 等待所有线程完成
for t in threads:
    t.join()
print "Exiting Main Thread"
{% endhighlight %}

#### 问题

这种方法的最为大家诟病的是会受到`GIL`(Global Interpreter Lock)全局锁的影响,使的整个程序变成了一个伪并发。至于为什么会有`GIL`，如何避免，就不是本文的重点也就不着重讨论了。有兴趣的读者可以查看一些[扩展](http://www.jeffknupp.com/blog/2012/03/31/pythons-hardest-problem/)[资料](https://wiki.python.org/moin/GlobalInterpreterLock)。这里就简要的概括下，方便大家理解。
由于CPython这种实现的局限性，为了能够使用更多的“非多线程安全”的扩展库，发明了`GIL`，即：所有的线程在同一时间只能有一个线程持有这个锁，并实际执行。那读者要说了，这不变串行了么，然并卵。好在`GIL`并不是始终被持有，在IO Blocking及类似操作下都会释放。也就是说如果你的程序是IO Bounding的那么就能从Python Thread中受益。反之如果你的程序是CPU Bound的纯python程序那使用Thread反而会因为上下文切换的损耗降低性能。
除此之外，这种实现方法还有一个问题就是实现复杂，可读性差。从例子可以看到，我们仅仅是为了多线程的执行`process_data`，却多写了近30行代码。这对于后期代码维护来说会带来不小的难度。


## 过时的方法：multiprocess.Pool + map/apply

multiprocessing = Pool = map,apply
multiprocessing.dummy = Pool
{% highlight python %}
import multiprocessing
import time


def my_sleep():
    print("Thread Start")
    time.sleep(1)


def main():
    thd_pool = multiprocessing.Pool(processes=3)
    thd_pool.map(my_sleep, range(10))
    thd_pool.close()
    thd_pool.join()

if __name__ == '__main__':
    main()
{% endhighlight %}

#### multiprocessing的一个问题
pickle

Workaround:
The problem is that multiprocessing must pickle things to sling them among
processes, and bound methods are not picklable. The workaround (whether you
consider it "easy" or not;-) is to add the infrastructure to your program to
allow such methods to be pickled, registering it with the copy_reg standard
library method.



## 正确的姿势：concurrency.future






## Reference:
- [Reddit上关于python多线程的讨论](https://www.reddit.com/r/Python/comments/1tyzw3/parallelism_in_one_line/)
- [concurrent.future的一个应用实例](http://www.dalkescientific.com/writings/diary/archive/2012/01/19/concurrent.futures.html)
- [Stackoverflow上关于如何使用多线程的讨论](http://stackoverflow.com/questions/9874042/using-pythons-multiprocessing-module-to-execute-simultaneous-and-separate-seawa)
- [apply和map的区别](http://stackoverflow.com/questions/8533318/python-multiprocessing-pool-when-to-use-apply-apply-async-or-map)
- [About the GIL](https://wiki.python.org/moin/GlobalInterpreterLock)
- [Pickling Error在stackoverflow上得讨论](http://stackoverflow.com/questions/1816958/cant-pickle-type-instancemethod-when-using-pythons-multiprocessing-pool-ma)
- [为什么不能pickle](http://bytes.com/topic/python/answers/552476-why-cant-you-pickle-instancemethods)
