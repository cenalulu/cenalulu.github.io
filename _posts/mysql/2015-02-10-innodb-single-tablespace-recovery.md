---
layout: article
title:  "Innodb单表数据物理恢复"
categories: mysql
toc: true
ads: true
image:
    teaser: /teaser/single_table_recovery.png
---

> 本文将介绍使用物理备份恢复Innodb单表数据的方法

>前言：
>
>随着innodb的普及，innobackup也成为了主流备份方式。物理备份对于新建slave，全库恢复的需求都能从容应对。
>但当面临单表数据误删，或者单表误drop的情况，如果使用物理全备进行恢复呢？ 
>下文将进行详细分析。 
>恢复过程中需要用到的工具，[percona data recover tool](https://launchpad.net/percona-innodb-recovery-tool)
>PS：以下所有方案仅支持 `innodb-file-per-table = 1` 的情况 
>注意： 以下操作非文档推荐，切勿在没有测试的情况下直接在production环境使用！！！


---


## 情况一：逻辑误操作，误删部分数据
这种情况可以用来自同一台机器的的最近一次物理备份中的ibd恢复覆盖，且备份后table没有被recreate过。
这种情况是最简单的，备份时的ibd文件（后称老ibd）中的space id和index id 与 新ibd的space id 和index id一致。
且和ibdata文件中的space id和index id一致。因此，物理文件可以直接覆盖做恢复。

以下是详细步骤

### 准备阶段


Step pre 1: 物理备份

{% highlight bash %}
{% raw %}
innobackupex --defaults-file=/usr/local/mysql3321/my.cnf --socket=/xfs/mysql3321/mysql.sock --user=root --password=password /xfs/backup/
{% endraw %}
{% endhighlight %}


Step pre 2 : 停止数据库对外服务

{% highlight bash %}
{% raw %}
service mysqld restart #（起在另外一个端口上）
{% endraw %}
{% endhighlight %}

或者 停止所有业务连接并且set global innodb_max_dirty_pages_pct  =0


### 操作阶段

Step 0 : apply log

{% highlight bash %}
{% raw %}
innobackupex --apply-log --defaults-file=/usr/local/mysql3321/my.cnf  /xfs/backup/2012-10-17_11-29-20/
{% endraw %}
{% endhighlight %}


Step 1 : 备份现在的ibd文件（可选）

{% highlight bash %}
{% raw %}
cp -a testibd.ibd testibd.bak
{% endraw %}
{% endhighlight %}

Step 2 : 舍弃现在ibd文件

{% highlight mysql %}
{% raw %}
mysql> alter table testibd discard tablespace
{% endraw %}
{% endhighlight %}

Step 3 : 复制备份ibd文件

{% highlight bash %}
{% raw %}
shell> cp /xfs/backup/2012-10-17_11-29-20/test/testibd.ibd /xfs/mysql3321/test/ 
shell> chown mysql:mysql /xfs/mysql3321/test/testibd.ibd
{% endraw %}
{% endhighlight %}

Step 4 : 导入ibd文件

{% highlight mysql %}
{% raw %}
mysql> alter table testibd import tablespace
{% endraw %}
{% endhighlight %}

 
---


## 情况二：误删 table，表结构已经被drop了

这种情况稍复杂，不过恢复过程还是比较容易操作的。由于table被drop后的space id会留空因此备份文件的space id不会被占用。

我们只需要重建表结构，然后把ibdata中该表的space id还原，物理文件可以直接覆盖做恢复了。

Step 1 : 重建表

{% highlight mysql %}
{% raw %}
mysql> alter table testibd import tablespace
{% endraw %}
{% endhighlight %}
mysql> create table testibd (UserID int);

Step 2 : 关闭mysql服务（必须）

{% highlight bash %}
{% raw %}
shell> service mysqld3321 stop
{% endraw %}
{% endhighlight %}

Step 3: 准备ibd文件  apply log

{% highlight bash %}
{% raw %}
shell> innobackupex --apply-log --defaults-file=/usr/local/mysql3321/my.cnf  /xfs/backup/2012-10-17_11-29-20/
{% endraw %}
{% endhighlight %}

Step 4 : 备份现在的ibd文件（可选）

{% highlight bash %}
{% raw %}
cp -a testibd.ibd testibd.bak
{% endraw %}
{% endhighlight %}

Step 5 : 复制备份ibd文件

{% highlight bash %}
{% raw %}
shell> cp -a /xfs/backup/2012-10-17_11-29-20/test/testibd.ibd /xfs/mysql3321/test/ 
shell> chown mysql:mysql /xfs/mysql3321/test/testibd.ibd
{% endraw %}
{% endhighlight %}

Step 6 : 使用percona recovery tool 修改ibdata 

{% highlight bash %}
{% raw %}
shell> /root/install/percona-data-recovery-tool-for-innodb-0.5/ibdconnect -o /xfs/mysql3321/ibdata1 -f /xfs/mysql3321/test/testibd.ibd -d test -t testibd
{% endraw %}
{% endhighlight %}

输出结果

{% highlight bash %}
{% raw %}
Initializing table definitions...
Processing table: SYS_TABLES
 - total fields: 10
 - nullable fields: 6
 - minimum header size: 5
 - minimum rec size: 21
 - maximum rec size: 555

Processing table: SYS_INDEXES
 - total fields: 9
 - nullable fields: 5
 - minimum header size: 5
 - minimum rec size: 29
 - maximum rec size: 165

Setting SPACE=1 in SYS_TABLE for `test`.`testibd`
Check if space id 1 is already used
Page_id: 8, next page_id: 4294967295
Record position: 65
Checking field lengths for a row (SYS_TABLES): OFFSETS: 16 8 50 3 2 0 0 0 0 0 
Db/table: infimum
Space id: 1768842857 (0x696E6669)
Next record at offset: 8D
Record position: 8D
Checking field lengths for a row (SYS_TABLES): OFFSETS: 16 11 17 24 32 36 40 48 52 52 
Db/table: SYS_FOREIGN
Space id: 0 (0x0)
Next record at offset: D5
Record position: D5
Checking field lengths for a row (SYS_TABLES): OFFSETS: 16 16 22 29 37 41 45 53 57 57 
Db/table: SYS_FOREIGN_COLS
Space id: 0 (0x0)
Next record at offset: 122
Record position: 122
Checking field lengths for a row (SYS_TABLES): OFFSETS: 16 12 18 25 33 37 41 49 53 53 
Db/table: test/testibd
Space id: 2 (0x2)
Next record at offset: 74
Space id 1 is not used in any of the records in SYS_TABLES
Page_id: 8, next page_id: 4294967295
Record position: 65
Checking field lengths for a row (SYS_TABLES): OFFSETS: 16 8 50 3 2 0 0 0 0 0 
Db/table: infimum
Space id: 1768842857 (0x696E6669)
Next record at offset: 8D
Record position: 8D
Checking field lengths for a row (SYS_TABLES): OFFSETS: 16 11 17 24 32 36 40 48 52 52 
Db/table: SYS_FOREIGN
Space id: 0 (0x0)
Next record at offset: D5
Record position: D5
Checking field lengths for a row (SYS_TABLES): OFFSETS: 16 16 22 29 37 41 45 53 57 57 
Db/table: SYS_FOREIGN_COLS
Space id: 0 (0x0)
Next record at offset: 122
Record position: 122
Checking field lengths for a row (SYS_TABLES): OFFSETS: 16 12 18 25 33 37 41 49 53 53 
Db/table: test/testibd
Space id: 2 (0x2)
Updating test/testibd (table_id 17) with id 0x01000000
SYS_TABLES is updated successfully
Initializing table definitions...
Processing table: SYS_TABLES
 - total fields: 10
 - nullable fields: 6
 - minimum header size: 5
 - minimum rec size: 21
 - maximum rec size: 555

Processing table: SYS_INDEXES
 - total fields: 9
 - nullable fields: 5
 - minimum header size: 5
 - minimum rec size: 29
 - maximum rec size: 165

Setting SPACE=1 in SYS_INDEXES for TABLE_ID = 17
Page_id: 11, next page_id: 4294967295
Record position: 65
Checking field lengths for a row (SYS_INDEXES): OFFSETS: 15 8 50 7 2 0 0 0 0 
TABLE_ID: 3798561113125514496
SPACE: 1768842857
Next record at offset: 8C
Record position: 8C
Checking field lengths for a row (SYS_INDEXES): OFFSETS: 15 8 16 22 29 35 39 43 47 
TABLE_ID: 11
SPACE: 0
Next record at offset: CE
Record position: CE
Checking field lengths for a row (SYS_INDEXES): OFFSETS: 15 8 16 22 29 36 40 44 48 
TABLE_ID: 11
SPACE: 0
Next record at offset: 111
Record position: 111
Checking field lengths for a row (SYS_INDEXES): OFFSETS: 15 8 16 22 29 36 40 44 48 
TABLE_ID: 11
SPACE: 0
Next record at offset: 154
Record position: 154
Checking field lengths for a row (SYS_INDEXES): OFFSETS: 15 8 16 22 29 35 39 43 47 
TABLE_ID: 12
SPACE: 0
Next record at offset: 22C
Record position: 22C
Checking field lengths for a row (SYS_INDEXES): OFFSETS: 15 8 16 22 29 44 48 52 56 
TABLE_ID: 17
SPACE: 2
Updating SPACE(0x00000001 , 0x01000000) for TABLE_ID: 17
sizeof(s)=4
Next record at offset: 74
SYS_INDEXES is updated successfully
{% endraw %}
{% endhighlight %}
  
 

Step 7 : 使用percona recovery tool 重新checksum ibdata

重复执行以下命令，直到程序没有输出为止。

{% highlight bash %}
{% raw %}
shell> /root/install/percona-data-recovery-tool-for-innodb-0.5/innochecksum -f /xfs/mysql3321/ibdata1
{% endraw %}
{% endhighlight %}

输出结果
{% highlight bash %}
{% raw %}
page 8 invalid (fails old style checksum)
page 8: old style: calculated = 0xF4AD74CB; recorded = 0xEECB309D
fixing old checksum of page 8
page 8 invalid (fails new style checksum)
page 8: new style: calculated = 0x6F0C29B4; recorded = 0x3D02308C
fixing new checksum of page 8
page 11 invalid (fails old style checksum)
page 11: old style: calculated = 0x3908087C; recorded = 0xF9E8D30C
fixing old checksum of page 11
page 11 invalid (fails new style checksum)
page 11: new style: calculated = 0xB26CFD77; recorded = 0xDB25D39D
fixing new checksum of page 11
{% endraw %}
{% endhighlight %}

 

Step 8 : 启动mysql服务

{% highlight bash %}
{% raw %}
shell> service mysqld3321 start
{% endraw %}
{% endhighlight %}

 
---

### 参考文档：

http://www.chriscalender.com/?p=28

http://www.mysqlperformanceblog.com/2011/05/13/connecting-orphaned-ibd-files/

http://blogs.innodb.com/wp/2012/04/innodb-transportable-tablespaces/

 http://www.mysqlperformanceblog.com/2012/01/25/how-to-recover-a-single-innodb-table-from-a-full-backup/

 

 
