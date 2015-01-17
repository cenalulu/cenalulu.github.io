---
layout: article
title:  "MySQL Server has gone away报错原因汇总分析"
categories: mysql
toc: true
ads: true
image:
    teaser: /teaser/mysql_has_gone_away.png
---

> 本文将总结和汇总MySQL Server has gone away这类报错发生的原因


> 背景：在平时和开发的交流 以及 在论坛回答问题的或称中会发现这个问题被问及的频率非常高。
> 程序中报错： MySQL server has gone away 是什么意思？ 如何避免？
> 因此，感觉有必要总结一下发生这个问题的原因。今天正好看到一篇外文blog总结的比较好，就翻译过来了
> 原文：http://ronaldbradford.com/blog/sqlstatehy000-general-error-2006-mysql-server-has-gone-away-2013-01-02/


--- 

## 原因1. MySQL 服务宕了

判断是否属于这个原因的方法很简单，执行以下命令，查看mysql的运行时长

{% highlight bash%}
{% raw %}
$ mysql -uroot -p -e "show global status like 'uptime';"
+---------------+-------+
| Variable_name | Value |
+---------------+-------+
| Uptime        | 68928 |
+---------------+-------+
1 row in set (0.04 sec)
{% endraw %}
{% endhighlight %}

或者查看MySQL的报错日志，看看有没有重启的信息

{% highlight bash%}
{% raw %}
$ tail /var/log/mysql/error.log
130101 22:22:30 InnoDB: Initializing buffer pool, size = 256.0M
130101 22:22:30 InnoDB: Completed initialization of buffer pool
130101 22:22:30 InnoDB: highest supported file format is Barracuda.
130101 22:22:30 InnoDB: 1.1.8 started; log sequence number 63444325509
130101 22:22:30 [Note] Server hostname (bind-address): '127.0.0.1'; port: 3306
130101 22:22:30 [Note]   - '127.0.0.1' resolves to '127.0.0.1';
130101 22:22:30 [Note] Server socket created on IP: '127.0.0.1'.
130101 22:22:30 [Note] Event Scheduler: Loaded 0 events
130101 22:22:30 [Note] /usr/sbin/mysqld: ready for connections.
Version: '5.5.28-cll'  socket: '/var/lib/mysql/mysql.sock'  port: 3306  MySQL Community Server (GPL)
{% endraw %}
{% endhighlight %}

如果uptime数值很大，表明mysql服务运行了很久了。说明最近服务没有重启过。 如果日志没有相关信息，也说明mysql服务最近没有重启过，可以继续检查下面几项内容。

--- 

## 原因2. 连接超时

如果程序使用的是长连接，则这种情况的可能性会比较大。 即，某个长连接很久没有新的请求发起，达到了server端的timeout，被server强行关闭。 此后再通过这个connection发起查询的时候，就会报错server has gone away

{% highlight bash%}
{% raw %}
$ mysql -uroot -p -e "show global variables like '%timeout';"
+----------------------------+----------+
| Variable_name              | Value    |
+----------------------------+----------+
| connect_timeout            | 30       |
| delayed_insert_timeout     | 300      |
| innodb_lock_wait_timeout   | 50       |
| innodb_rollback_on_timeout | OFF      |
| interactive_timeout        | 28800    |
| lock_wait_timeout          | 31536000 |
| net_read_timeout           | 30       |
| net_write_timeout          | 60       |
| slave_net_timeout          | 3600     |
| wait_timeout               | 28800    |
+----------------------------+----------+
mysql> SET SESSION wait_timeout=5;


# Wait 10 seconds

mysql> SELECT NOW();
ERROR 2006 (HY000): MySQL server has gone away
No connection. Trying to reconnect...
Connection id:    132361
Current database: *** NONE ***

+---------------------+
| NOW()               |
+---------------------+
| 2013-01-02 11:31:15 |
+---------------------+
1 row in set (0.00 sec)
{% endraw %}
{% endhighlight %}


---

## 原因3. 进程在server端被主动kill

这种情况和情况2相似，只是发起者是DBA或者其他job。发现有长时间的慢查询执行kill xxx导致。

{% highlight bash %}
{% raw %}
$ mysql -uroot -p -e "show global status like 'com_kill'"
+---------------+-------+
| Variable_name | Value |
+---------------+-------+
| Com_kill      | 0     |
+---------------+-------+

{% endraw %}
{% endhighlight %}

---

## 原因4. Your SQL statement was too large.

当查询的结果集超过 `max_allowed_packet` 也会出现这样的报错。定位方法是打出相关报错的语句。 用`select * into outfile` 的方式导出到文件，查看文件大小是否超过 `max_allowed_packet` ，如果超过则需要调整参数，或者优化语句。

{% highlight bash %}
{% raw %}

mysql> show global variables like 'max_allowed_packet';
+--------------------+---------+
| Variable_name      | Value   |
+--------------------+---------+
| max_allowed_packet | 1048576 |
+--------------------+---------+
1 row in set (0.00 sec)

# 修改参数：

mysql> set global max_allowed_packet=1024*1024*16;
mysql> show global variables like 'max_allowed_packet';
+--------------------+----------+
| Variable_name      | Value    |
+--------------------+----------+
| max_allowed_packet | 16777216 |
+--------------------+----------+
1 row in set (0.00 sec)
{% endraw %}
{% endhighlight %}
 
