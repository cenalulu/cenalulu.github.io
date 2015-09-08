---
layout: article
title: "Innodb Transparent Page Compression"
modified:
categories: mysql
#excerpt:
#tags: []
#image:
#    feature: /teaser/xxx
#    teaser: /teaser/xxx
#    thumb:
date: 2015-09-08T22:14:51+01:00
---



> 文章欢迎转载，但转载时请保留本段文字，并置于文章的顶部
> 作者：卢钧轶(cenalulu)
> 本文原文地址：<http://cenalulu.github.io{{ page.url }}>


### 什么punch hole

See more on: http://man7.org/linux/man-pages/man2/fallocate.2.html
https://en.wikipedia.org/wiki/Sparse_file

### puch hole的使用场景

在LWN上有很多网友都发表了自己对`punch hole`实用价值的看法。一部分评论认为TRIM的存在使得`punch hole`缺乏实用价值。在总结了其他网友的看法以后，博主发现`punch hole`的主要使用场景有以下几个特征：

- 无法确切知道需要申请的空间，但是可以确定最大值
- 申请空间后会有一定规模的空间释放（频率有高有低）
- 有一定性能要求

总结一下符合这些特征最贴切的使用场景就是虚拟环境的虚拟磁盘。用过VMWare Workstation的同学肯定都知道虚拟机在宿主机上就是一个大文件。这个文件的地址空间成为了虚拟机中物理磁盘的大小。实际使用中，有时希望虚拟环境内部的空间释放（删除一个虚拟磁盘）能够直接反应到宿主机上。这样宿主机就可以节省出更多的空闲资源。此时通过`punch hole`就能很好的这个场景下得需求。

### MySQL 5.7 如何使用punch hole的


## Ref

1: [InnoDB Transparent Page Compression](http://mysqlserverteam.com/innodb-transparent-page-compression/)
2: [First day with InnoDB transparent page compression](http://smalldatum.blogspot.ie/2015/08/first-day-with-innodb-transparent-page.html)
3: [About puch-hole on lwn](https://lwn.net/Articles/415889/)
