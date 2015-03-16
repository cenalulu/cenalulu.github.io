---
layout: article
title:  "全局唯一ID生成方案对比"
categories: mysql
toc: true
ads: true
image:
    teaser: /teaser/guid.jpg
---


> 汇总了各大公司的全局唯一ID生成方案，并做了一个简单的优劣比较

> 背景：在实现大型分布式程序时，通常会有全局唯一ID（也成GUID）生成的需求，用来对每一个对象标识一个代号。本文就列举了博主收集的各种全局唯一ID生成的方案，做一个简单的类比和备忘。


---

## GUID的基本需求
一般对于唯一ID生成的要求主要这么几点：

- 毫秒级的快速响应
- 可用性强
- prefix有连续性方便DB顺序存储
- 体积小，8字节为佳


---

## 业界成熟方案列举
目前看到过的唯一ID生成方法主要有以下几种：

- [UUID](http://docs.oracle.com/javase/7/docs/api/java/util/UUID.html) 16字节
- Twitter的[Snowflake](http://engineering.twitter.com/2010/06/announcing-snowflake.html) 8字节
- [Flikr的数据库自增](http://code.flickr.net/2010/02/08/ticket-servers-distributed-unique-primary-keys-on-the-cheap/) 4/8字节
- [Instagram的存储过程](http://instagram-engineering.tumblr.com/post/10853187575/sharding-ids-at-instagram) 8字节
- [基于MySQL UUID的变种](http://mysql.rjweb.org/doc.php/uuid) 16字节


---

## 各个方案优劣的对比
四种方案各有优劣，下面简要描述以下：

- UUID：
    - 优：java自带，好用。
    - 劣：占用空间大
 
- Snowflake： timestamp + work number + seq number
    - 优：可用性强，速度快
    - 劣：需要引入zookeeper 和独立的snowflake专用服务器
 
- Flikr：基于int/bigint的自增
    - 优：开发成本低
    - 劣：如果需要高性能，需要专门一套MySQL集群只用于生成自增ID。可用性也不强
 
- Instagram：41b ts + 13b shard id + 10b increment seq
    - 优： 开发成本低
    - 劣： 基于postgreSQL的存储过程，通用性差

- UUID变种：timestamp + machine number + random (具体见：[变种介绍](http://mysql.rjweb.org/doc.php/uuid)
    - 优： 开发成本低
    - 劣： 基于MySQL的存储过程，性能较差



