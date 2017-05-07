---
layout: article
title: Facebook OnlineSchemaChange 再开源和改进介绍
categories: mysql
#excerpt:
#tags: []
image:
    teaser: /teaser/osc.jpg
#    thumb:
---


> 本文会简要介绍，OnlineSchemaChange在经历从PHP到Python重写后的改进和变化

> 文章欢迎转载，但转载时请保留本段文字，并置于文章的顶部
> 作者：卢钧轶(cenalulu)
> 本文原文地址：<http://cenalulu.github.io{{ page.url }}>

### 前言

Facebook早在2009年就开源了OnlineSchemaChange.php.  该工具主要设计初衷是用于补充当时MySQL对于在线表结构变更支持的空白，尽可能的减少表结构变更时对业务的影响。而在过去的几个月中这个工具经历了从PHP到Python重写，以及功能的新增和性能的改进。今天，重写后的OnlineSchemaChange正式宣布开源，可通过此链接访问：<https://github.com/facebookincubator/OnlineSchemaChange>


## 设计初衷和困境

最早，OSC是为了解决MySQL在进行表结构变更时锁表所带来的业务影响。同时，它也满足一部分DDL无法提供的功能。例如：`ALTER TABLE IGNORE ... ENGINE=INNODB`。
然而在PHP的使用过程中我们发现设计上缺陷和程序编写方式的问题导致这个工具的可扩展性较差，并且无法更好的进行功能测试。随着时间的积累，往这个工具增加新功能的难度越来越高，甚至修复bug都成了一个不可能完成的任务。同时功能测试的缺失也成为了吸纳社区贡献的一个重大阻碍，致使整个项目的活跃度下降。
因此在去年我们决定重写这个工具，同时加入更多我们向往已久的功能。

![osc_archi](/images/mysql/osc/osc.png)

## 变化和改进

### 使用便捷

之前开源的OSC更多的像是一个概念和一段代码，本身无法直接使用。用户需要自己把核心逻辑封装成一个可执行的脚本。这个大大增加的OSC的可用度也从而导致了社区的接纳度不高。新版本的OSC.py是一个命令行可执行的脚本，很大程度上提高了易用性成为一个下载即可使用的工具。
同时，OSC.py的核心逻辑也独立成为Python Module存在。如果你的运维整体架构是基于Python搭建的那么新的OSC.py将可以很容易的融合到你的工具集当中。


### 可测试性

受到`mysql-test-run`的启发，新的OSC实现了一个类似的测试案例设计。及时是一个不懂Python的用户也可以非常容易的写出一个基于JSON+SQL的测试案例，提交一个issue来描述自己遇到的bug。同时这也使得吸纳社区patch的可靠性大幅提高。
同时受益于Python语言本身，整个工具也实现很高的单元测试覆盖度，可靠性有了很好的保障。

### 可靠性

和目前所有开源的在线表结构变更工具不同，OSC.py实现了一致性检验的功能。在Facebook数据一致性高于一切。一致性的检验可以让我们非常放心在任何时刻进行任何表结构变更而不用担心因工具bug而造成的数据丢失或者损毁。同时，一致性校验也是一种对社区用户负责的态度。MySQL的运行环境和配置参数千变万化，而Facebook的线上环境所能涵盖的只是一小部分。能在FB正常运行并不意味着这个工具就可以对bug免疫。一致性校验的存在可以让OSC.py优雅的避免各种环境变化所可能带来的潜在bug对数据的损坏。

要详细了解更多OSC.py带来的新特性可以查看这个[wiki page](https://github.com/facebookincubator/OnlineSchemaChange/wiki/Special-Things-About-OSC)


## 项目的展望

随着`Row Based Replication`的普及和在Facebook内部的全面部署，我们将会增加基于RBR binlog增量记录的功能，从而完全避免trigger模式带来的性能损耗。同时，我们也将会将原生在线表结构变更的支持增加到智能模式中，在实现一个工具满足所有表结构变更的需求的同时达到最小的不可用时间。

最后我们也非常希望和开源社区一起对OSC进行改进和开发，使之能成为一个更为可靠高效的DBA工具。

最后附上github的repo地址：[https://github.com/facebookincubator/OnlineSchemaChange](https://github.com/facebookincubator/OnlineSchemaChange)





