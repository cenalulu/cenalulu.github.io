---
layout: article
title: "关于MySQL密码你应该知道的那些事"
modified:
categories: mysql
#excerpt:
tags: [mysql, password]
image:
#  feature:
  teaser: /teaser/password.jpg
#  thumb:
date: 2015-02-28T01:16:51+08:00
---

> 本文将介绍MySQL用户密码相关的一些知识，以及5.6中对于安全性的一些改进


## MySQL用户密码是如何生成和保存的

如果你已经接触MySQL一段时间了，那么想必你一定知道MySQL把所有用户的用户名和密码的密文存放在`mysql.user`表中。大致的形式如下：
{% highlight mysql %}
{% raw %}
mysql [localhost] {msandbox} (mysql) > select user,password from mysql.user;
+----------------+-------------------------------------------+
| user           | password                                  |
+----------------+-------------------------------------------+
| root           | *6C387FC3893DBA1E3BA155E74754DA6682D04747 |
| plain_password | *861D75A7F79DE84B116074893BBBA7C4F19C14FA |
| msandbox       | *6C387FC3893DBA1E3BA155E74754DA6682D04747 |
| msandbox       | *6C387FC3893DBA1E3BA155E74754DA6682D04747 |
| msandbox_rw    | *6C387FC3893DBA1E3BA155E74754DA6682D04747 |
| msandbox_rw    | *6C387FC3893DBA1E3BA155E74754DA6682D04747 |
| msandbox_ro    | *6C387FC3893DBA1E3BA155E74754DA6682D04747 |
| msandbox_ro    | *6C387FC3893DBA1E3BA155E74754DA6682D04747 |
| rsandbox       | *B07EB15A2E7BD9620DAE47B194D5B9DBA14377AD |
+----------------+-------------------------------------------+
9 rows in set (0.01 sec)* 
{% endraw %}
{% endhighlight %}

可见MySQL在其内部是不存放用户的明文密码的（这个也是一般程序对于敏感信息的最基础保护）。一般来说密文是通过不可逆加密算法得到的。这样即使敏感信息泄漏，除了暴力破解是无法快速从密文直接得到明文的。


## MySQL用的是哪种不可逆算法来加密用户密码的

MySQL实际上是使用了两次SHA1夹杂一次unhex的方式对用户密码进行了加密。具体的算法可以用公式表示：`password_str = concat('*', sha1(unhex(sha1(password))))`
我们可以用下面的方法做个简单的验证。
{% highlight mysql %}
{% raw %}
mysql [localhost] {msandbox} (mysql) > select password('mypassword'),concat('*',sha1(unhex(sha1('mypassword'))));
+-------------------------------------------+---------------------------------------------+
| password('mypassword')                    | concat('*',sha1(unhex(sha1('mypassword')))) |
+-------------------------------------------+---------------------------------------------+
| *FABE5482D5AADF36D028AC443D117BE1180B9725 | *fabe5482d5aadf36d028ac443d117be1180b9725   |
+-------------------------------------------+---------------------------------------------+
1 row in set (0.01 sec)
{% endraw %}
{% endhighlight %}



## MySQL用户密码的不安全性

其实MySQL在5.6版本以前，对于对于安全性的重视度非常低，对于用户密码也不例外。例如，MySQL对于binary log中和用户密码相关的操作是不加密的。如果你向MySQL发送了例如`create user`,`grant user ... identified by`这样的携带初始明文密码的指令，那么会在binary log中原原本本的被还原出来。我们通过下面的例子来验证

创建一个用户
{% highlight mysql %}
{% raw %}
mysql [localhost] {msandbox} (mysql) > create user plain_password identified by 'plain_pass';
Query OK, 0 rows affected (0.00 sec)
{% endraw %}
{% endhighlight %}

用mysqlbinlog查看二进制日志
{% highlight bash %}
{% raw %}
shell> mysqlbinlog binlog.000001
# at 106
#150227 23:37:59 server id 1  end_log_pos 223   Query   thread_id=1 exec_time=0 error_code=0
use mysql/*!*/;
SET TIMESTAMP=1425051479/*!*/;
SET @@session.pseudo_thread_id=1/*!*/;
SET @@session.foreign_key_checks=1, @@session.sql_auto_is_null=1, @@session.unique_checks=1, @@session.autocommit=1/*!*/;
SET @@session.sql_mode=0/*!*/;
SET @@session.auto_increment_increment=1, @@session.auto_increment_offset=1/*!*/;
/*!\C latin1 *//*!*/;
SET @@session.character_set_client=8,@@session.collation_connection=8,@@session.collation_server=8/*!*/;
SET @@session.lc_time_names=0/*!*/;
SET @@session.collation_database=DEFAULT/*!*/;
create user plain_password identified by 'plain_pass'
/*!*/;
DELIMITER ;
# End of log file
ROLLBACK /* added by mysqlbinlog */;
/*!50003 SET COMPLETION_TYPE=@OLD_COMPLETION_TYPE*/;
{% endraw %}
{% endhighlight %}



## MySQL5.6中对于用户密码的安全性加强

好在MySQL5.6开始对安全性有了一定的重视，为了杜绝明文密码出现在binlog中的情况，MySQL引入了一系列会以密文方式记录二进制日志的命令：

- REATE USER ... IDENTIFIED BY ...
- GRANT ... IDENTIFIED BY ...
- SET PASSWORD ...
- SLAVE START ... PASSWORD = ...              (as of 5.6.4)
- CREATE SERVER ... OPTIONS(... PASSWORD ...) (as of 5.6.9)
- ALTER SERVER ... OPTIONS(... PASSWORD ...)  (as of 5.6.9)

细心你的也许会发现，`change master to master_password=''`命令不在这个范畴中。这也就意味着MySQL5.6中仍然使用这样的语法来启动replication时有安全风险的。这也就是为什么5.6中使用带有明文密码的`change master to`时会有warning提示，具体如下：


{% highlight mysql %}
{% raw %}
slave1 [localhost] {msandbox} ((none)) > change master to master_host='127.0.0.1',master_port =21288,master_user='rsandbox',master_password='rsandbox',master_auto_position=1;
Query OK, 0 rows affected, 2 warnings (0.04 sec)

slave1 [localhost] {msandbox} ((none)) > show warnings;
+-------+------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| Level | Code | Message                                                                                                                                                                                                                                                                              |
+-------+------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| Note  | 1759 | Sending passwords in plain text without SSL/TLS is extremely insecure.                                                                                                                                                                                                               |
| Note  | 1760 | Storing MySQL user name or password information in the master info repository is not secure and is therefore not recommended. Please consider using the USER and PASSWORD connection options for START SLAVE; see the 'START SLAVE Syntax' in the MySQL Manual for more information. |
+-------+------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
2 rows in set (0.00 sec)

{% endraw %}
{% endhighlight %}


reference:
<http://www.pythian.com/blog/hashing-algorithm-in-mysql-password-2/>

