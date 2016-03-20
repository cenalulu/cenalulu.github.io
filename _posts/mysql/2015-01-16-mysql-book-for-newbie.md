---
layout: article
title:  "MySQL入门书籍和方法分享"
categories: mysql
toc: true
ads: true
image:
    teaser: /teaser/mysql_newbie_book.jpg
---

> 本文罗列了一些适用于MySQL及运维入门和进阶使用的书籍。

> 背景：各大论坛上总是有很多同学咨询想学习数据库，或者是为入行DBA做些准备。几年来作为一个MySQL DBA的成长过程有一些积累和感悟，特此拿出来和大家分享。

> **申明：本篇博客原来对每一本书都附上了ppurl的下载链接。无奈该网站由于涉及版权原因闭站了。因此，目前暂不提供书籍链接，待找到好的PDF下载源的时候再不上。大家如果有下载需求可以考虑百度搜索或者邮件询问我。[我的联系方式]({{ site.url }}/about/)**


---

## SQL 入门

在准备成为MySQL DBA之前，能熟练的编写SQL是一个必要条件。exists 和 join之间的等价转换；基本的行列转换；SQL 循环等的熟练掌握对之后的运维和调优工作都有很大的帮助。

推荐书籍：

1. SQL Cookbook  [原版]() [中文版]() 一本循序渐进的SQL指导手册。每一种业务需求，书中都用MySQL，SQL Server，Oracle三种语法进行解析。可以顺序的作为学习书籍，也可以之后作为工具书籍查阅。
2. The Art of SQL [原版]() [中文版]() 将SQL调优模拟成一场战役，进行战术分析。更多的是传授SQL架构设计方面的知识，实际的调优实例不多，翻译很烂，建议看原版 
3. SQL应用重构 [原版]()
4. OReilly.MySQL.Stored.Procedure.Programming.Mar.2006.chm [原版]() 学习MySQL 存储过程语法和编写的最好教材。虽然版本比较老，但是大部分的语法都没有变更，比较推荐。


---

## MySQL 入门&精通

如果你已经熟练掌握了基本的SQL编写技巧，就可以进入对于MySQL产品本身的入门学习了

推荐书籍：

1. High Performance MySQL [原版]() [中文版]() MySQL界的圣经，目前已经出到第三版。非常详细的介绍了MySQL运维的各个部分，可以通读了解，也可以作为工具书进行查阅。
2. 深入浅出MySQL数据库开发、优化与管理维护 [原版]() [中文版]() 中文原创书籍中比较适合入门的一本。教粗浅的介绍了MySQL的相关特性，比较适合MySQL运维的入门
3. MySQL技术内幕 innodb 存储引擎 [原版]() [中文版]()  很详细的从代码层面分析了Innodb的内部结构，适合深入学习innodb


---

## 其他学习资源

MySQL入门除了通过书本学习理论知识以外还有其他各种方式可以进行学习。

1. Our Episode [链接地址](http://www.oursql.com/) 一个类似于MySQL电台的节目 ，每周会定期出一个音频讨论一个MySQL话题。 是学习MySQL&学习英语的好选择
2. MySQL Planet 几乎涵盖了所有MySQL业界大牛的博客RSS汇总。强烈建议订阅！
3. MOOC 各类公开课程网站都会有免费得MySQL入门课程试听。这里就不一一列举了。


---

## 运维&数据思想

推荐书籍：

1.  The Art of Capacity Planning [原版]() [中文版]() 作为运维免不了要做容量规划和容量预测。这本书是一个很好的开始。
2.  Beautiful Data: The Stories Behind Elegant Data Solutions  [原版]() [中文版]() 对数据的敏感对于数据库运维是一个重要特质。

