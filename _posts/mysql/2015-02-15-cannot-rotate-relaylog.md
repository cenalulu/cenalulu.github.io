---
layout: article
title:  "关于Relay Log无法自动删除的问题"
categories: mysql
toc: true
ads: true
image:
   teaser: /teaser/delete_relay.jpg
---

> 本文介绍了一次运维实践中relay-log长期无法自动删除的原因和解决过程


> 背景： 今天在运维一个mysql实例时，发现其数据目录下的relay-log 长期没有删除，已经堆积了几十个relay-log。 然而其他作为Slave服务器实例却没有这种情况。



## 现象分析


通过收集到的信息，综合分析后发现relay-log无法自动删除和以下原因有关。

- 该实例原先是一个Slave:导致relay-log 和 relay-log.index的存在
- 该实例目前已经不是Slave:由于没有了IO-Thread，导致relay-log-purge 没有起作用（ 这也是其他Slave实例没有这种情况的原因，因为IO-thread会做自动rotate操作）。
- 该实例每天会进行日常备份:Flush logs的存在，导致每天会生成一个relay-log
- 该实例没有配置expire-logs-days:导致flush logs时，也不会做relay-log清除

简而言之就是： 一个实例如果之前是Slave，而之后停用了（stop slave），且没有配置expire-logs-days的情况下，会出现relay-log堆积的情况。
 

## 深入分析

顺带也和大家分享下MySQL 内部Logrotate的机制

### Binary Log rotate机制：
- Rotate：每一条binary log写入完成后，都会判断当前文件是否超过 `max_binlog_size`，如果超过则自动生成一个binlog file
- Delete：expire-logs-days 只在 实例启动时 和 flush logs 时判断，如果文件访问时间早于设定值，则purge file
 

### Relay Log rotate 机制：
- Rotate：每从Master fetch一个events后，判断当前文件是否超过 `max_relay_log_size` 如果超过则自动生成一个新的relay-log-file
- Delete：`purge-relay-log` 在SQL Thread每执行完一个events时判断，如果该relay-log 已经不再需要则自动删除
- Delete：`expire-logs-days` 只在 实例启动时 和 flush logs 时判断，如果文件访问时间早于设定值，则purge file  （同Binlog file）  (updated: expire-logs-days和relaylog的purge没有关系)
PS： 因此还是建议配置 `expire-logs-days` ， 否则当我们的外部脚本因意外而停止时，还能有一层保障。

因此建议当slave不再使用时，通过reset slave来取消relaylog，以免出现relay-log堆积的情况。
