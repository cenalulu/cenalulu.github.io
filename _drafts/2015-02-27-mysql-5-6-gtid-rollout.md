---
layout: article
title: "MySQL 5.6 GTID上线须知和可选上线方案"
modified:
categories: mysql
#excerpt:
tags: [mysql, GTID, rollout, 上线]
#image:
#  feature:
#  teaser:
#  thumb:
date: 2015-02-27T22:51:17+08:00
---

MySQL GTID上线方案一直是一个为人诟病的设计，官方文档上给出的居然是一个停止写入后，修改配置重启的方案。这样的停机方案在生产环境中几乎是无法接受的，甚至缺乏一个在线升级方案被作为了 [一个bug](http://bugs.mysql.com/bug.php?id=69059)出现在了MySQL的Buglist中。
虽然官方计划在`MySQL 5.7`中将`gtid_mode`修改为动态变量，见 [MySQL WorkLoad](http://dev.mysql.com/worklog/task/?id=7083)，这显然是一个比较遥远的期许。那么在目前，如果希望减少停机时间，对production环境的MySQL升级为GTID有什么好的方案呢？

> a GTID enabled database was not designed to replicate from/to a GTID disabled database. To enforce that, a check is done at slave start up validating that the master GTID mode is compatible with the slave mode. This is a serious hurdle.
