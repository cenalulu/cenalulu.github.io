---
layout: article
title: "10分钟学会理解和解决MySQL乱码问题"
modified:
categories: mysql
#excerpt:
#tags: []
image:
#    feature: /teaser/xxx
    teaser: /teaser/mojibake.jpg
#    thumb:
date: 2015-03-05T15:44:52+08:00
---

> 本文将详细介绍MySQL乱码的成因和具体的解决方案

> 在阅读本文之前，强烈建议对字符集编码概念还比较模糊的同学 阅读下博主之前对相关概念的一篇科普：[十分钟搞清字符集和字符编码](http://cenalulu.github.io/linux/character-encoding/)

## MySQL出现乱码的原因

要了解为什么会出现乱码，我们就先要理解：从客户端发起请求，到MySQL存储数据，再到下次从表取回客户端的过程中，哪些环节会有编码/解码的行为。为了更好的解释这个过程，博主制作了两张流程图，分别对应存入和取出两个阶段。

#### 存入MySQL经历的编码转换过程

![mysqlflow](/images/mysql/mojibake/flow.png)
上图中有3次编码/解码的过程（红色箭头）。三个红色箭头分别对应：客户端编码，MySQL Server解码，Client编码向表编码的转换。其中Terminal可以是一个Bash，一个web页面又或者是一个APP。本文中我们假定Bash是我们的Terminal，即用户端的输入和展示界面。图中每一个框格对应的行为如下：

- 在terminal中使用输入法输入
- terminal根据字符编码转换成二进制流
- 二进制流通过MySQL客户端传输到MySQL Server
- Server通过character-set-client解码
- 判断character-set-client和目标表的charset是否一致
- 如果不一致则进行一次从client-charset到table-charset的一次字符编码转换
- 将转换后的字符编码二进制流存入文件中


#### 从MySQL表中取出数据经历的编码转换过程

![mysqlflow](/images/mysql/mojibake/flow2.png)
上图有3次编码/解码的过程（红色箭头）。上图中三个红色箭头分别对应：客户端解码展示，MySQL Server根据`character-set-client`编码，表编码向`character-set-client`编码的转换。

- 从文件读出二进制数据流
- 用表字符集编码进行解码
- 将数据转换为character-set-client的编码
- 使用character-set-client编码为二进制流
- Server通过网络传输到远端client
- client通过bash配置的字符编码展示查询结果


#### 造成MySQL乱码的原因

_1. 存入和取出时对应环节的编码不一致_
这个会造成乱码是显而易见的。我们把存入阶段的三次编解码使用的字符集编号为C1,C2,C3（图一从左到右）；取出时的三个字符集依次编号为C1',C2',C3'（从左到右）。那么存入的时候bash `C1`用的是UTF-8编码，取出的时候,`C1'`我们却使用了windows终端（默认是GBK编码），那么结果几乎一定是乱码。又或者存入MySQL的时候`set names utf8`(`C2`)，而取出的时候却使用了`set names gbk`(`C2'`)，那么结果也必然是乱码

_2. 单个流程中三步的编码不一致_
即上面任意一幅图中的同方向的三步中，只要两步或者两部以上的编码有不一致就有可能出现编解码错误。如果差异的两个字符集之间无法进行无损编码转换（下文会详细介绍），那么就一定会出现乱码。例如：我们的shell是UTF8编码，MySQL的`character-set-client`配置成了GBK，而表结构却又是`charset=utf8`，那么毫无疑问的一定会出现乱码。
这里我们就简单演示下这种情况

{% highlight mysql %}
{% raw %}
master [localhost] {msandbox} (test) > create table charset_test_utf8 (id int primary key auto_increment, char_col varchar(50)) charset = utf8;
Query OK, 0 rows affected (0.04 sec)

master [localhost] {msandbox} (test) > set names gbk;
Query OK, 0 rows affected (0.00 sec)

master [localhost] {msandbox} (test) > insert into charset_test_utf8 (char_col) values ('中文');
Query OK, 1 row affected, 1 warning (0.01 sec)

master [localhost] {msandbox} (test) > show warnings;
+---------+------+---------------------------------------------------------------------------+
| Level   | Code | Message                                                                   |
+---------+------+---------------------------------------------------------------------------+
| Warning | 1366 | Incorrect string value: '\xAD\xE6\x96\x87' for column 'char_col' at row 1 |
+---------+------+---------------------------------------------------------------------------+
1 row in set (0.00 sec)

master [localhost] {msandbox} (test) > select id,hex(char_col),char_col from charset_test_utf8;
+----+----------------+----------+
| id | hex(char_col)  | char_col |
+----+----------------+----------+
|  1 | E6B6933FE69E83 | �?��        |
+----+----------------+----------+
1 row in set (0.01 sec)
{% endraw %}
{% endhighlight %}


#### 关于MySQL的编/解码

既然系统之间是按照二进制流进行传输的，那直接把这串二进制流直接存入表文件就好啦。为什么在存储之前还要进行两次编解码的操作呢？

- Client to Server的编解码的原因是MySQL需要对传来的二进制流做语法和词法解析。如果不做编码解析和校验，我们甚至没法知道传来的一串二进制流是`insert`还是`update`。
- File to Engine的编解码是为知道二进制流内的分词情况。举个简单的例子：我们想要从表里取出某个字段的前两个字符，执行了一句形如`select left(col,2) from table`的语句，存储引擎从文件读入该column的值是`E4B8ADE69687`。那么这个时候如果我们按照GBK把这个值分割成`E4B8`,`ADE6`,`9687`三个字，并那么返回客户端的值就应该是`E4B8ADE6`；如果按照UTF8分割成`E4B8AD`,`E69687`，那么就应该返回`E4B8ADE69687`两个字。可见，如果在从数据文件读入数据后，不进行编解码的话在存储引擎内部是无法进行字符级别的操作的。


---


## 关于错进错出

在MySQL中最常见的乱码问题的起因就是把`错进错出`神话。所谓的错进错出就是，客户端(web或shell)的字符编码和最终表的字符编码格式不同，但是只要保证存和取两次的字符集编码一致就仍然能够获得没有乱码的输出的这种现象。但是，错进错出并不是对于任意两种字符集编码的组合都是有效的。我们假设客户端的编码是C，MySQL表的字符集编码是S。那么为了能够错进错出，需要满足以下两个条件

> MySQL接收请求时，从C编码后的二进制流在被S解码时能够无损 
MySQL返回数据是，从S编码后的二进制流在被C解码时能够无损

#### 编码无损转换

那么什么是有损转换，什么是无损转换呢？假设我们要把用编码A表示的字符X，转化为编码B的表示形式，而编码B的字形集中并没有X这个字符，那么此时我们就称这个转换是有损的。那么，为什么会出现两个编码所能表示字符集合的差异呢？如果大家看过博主之前的那篇 [十分钟搞清字符集和字符编码]({{ site.url }}/linux/character-encoding/)，或者对字符编码有基础理解的话，就应该知道每个字符集所支持的字符数量是有限的，并且各个字符集涵盖的文字之间存在差异。UTF8和GBK所能表示的字符数量范围如下

- GBK单个字符编码后的取值范围是：`8140` - `FEFE` 其中不包括`**7E`，总共字符数在27000左右
- UTF8单个字符编码后，按照字节数的不同，取值范围如下表：

<img src="/images/mysql/mojibake/utf8.png" style="max-width:80%" />

由于UTF-8编码能表示的字符数量远超GBK。那么我们很容易就能找到一个从UTF8到GBK的有损编码转换。我们用字符映射器（见下图）找出了一个明显就不在GBK编码表中的字符，尝试存入到GBK编码的表中。并再次取出查看有损转换的行为
字符信息具体是：`ਅ GURMUKHI LETTER A Unicode: U+0A05, UTF-8: E0 A8 85`

<img src="/images/mysql/mojibake/charset.png" style="max-width:50%" />

在MySQL中存储的具体情况如下：
{% highlight mysql %}
{% raw %}
master [localhost] {msandbox} (test) > create table charset_test_gbk (id int primary key auto_increment, char_col varchar(50)) charset = gbk;
Query OK, 0 rows affected (0.00 sec)

master [localhost] {msandbox} (test) > set names utf8;
Query OK, 0 rows affected (0.00 sec)

master [localhost] {msandbox} (test) > insert into charset_test_gbk (char_col) values ('ਅ');
Query OK, 1 row affected, 1 warning (0.01 sec)

master [localhost] {msandbox} (test) > show warnings;
+---------+------+-----------------------------------------------------------------------+
| Level   | Code | Message                                                               |
+---------+------+-----------------------------------------------------------------------+
| Warning | 1366 | Incorrect string value: '\xE0\xA8\x85' for column 'char_col' at row 1 |
+---------+------+-----------------------------------------------------------------------+
1 row in set (0.00 sec)

master [localhost] {msandbox} (test) > select id,hex(char_col),char_col,char_length(char_col) from charset_test_gbk;
+----+---------------+----------+-----------------------+
| id | hex(char_col) | char_col | char_length(char_col) |
+----+---------------+----------+-----------------------+
|  1 | 3F            | ?        |                     1 |
+----+---------------+----------+-----------------------+
1 row in set (0.00 sec)
{% endraw %}
{% endhighlight %}

出错的部分是在编解码的第3步时发生的。具体见下图
![flow2](/images/mysql/mojibake/flow3.png)

可见MySQL内部如果无法找到一个UTF8字符所对应的GBK字符时，就会转换成一个错误mark（这里是问号）。而每个字符集在程序实现的时候内部都约定了当出现这种情况时的行为和转换规则。例如：UTF8中无法找到对应字符时，如果不抛错那么就将该字符替换成`� `(U+FFFD)

那么是不是任何两种字符集编码之间的转换都是有损的呢？并非这样，转换是否有损取决于以下几点：

- 被转换的字符是否同时在两个字符集中
- 目标字符集是否能够对不支持字符，保留其原有表达形式

关于第一点，刚才已经通过实验来解释过了。这里来解释下造成有损转换的第二个因素。从刚才的例子我们可以看到由于GBK在处理自己无法表示的字符时的行为是：用`错误标识`替代，即`0x3F`。而有些字符集（例如latin1）在遇到自己无法表示的字符时，会保留原字符集的编码数据，并跳过忽略该字符进而处理后面的数据。如果目标字符集具有这样的特性，那么就能够实现这节最开始提到的`错进错出`的效果。
我们来看下面这个例子
{% highlight mysql %}
{% raw %}
master [localhost] {msandbox} (test) > create table charset_test (id int primary key auto_increment, char_col varchar(50)) charset = latin1;
Query OK, 0 rows affected (0.03 sec)

master [localhost] {msandbox} (test) > set names latin1;
Query OK, 0 rows affected (0.00 sec)

master [localhost] {msandbox} (test) > insert into charset_test (char_col) values ('中文');
Query OK, 1 row affected (0.01 sec)

master [localhost] {msandbox} (test) > select id,hex(char_col),char_col from charset_test;
+----+---------------+----------+
| id | hex(char_col) | char_col |
+----+---------------+----------+
|  2 | E4B8ADE69687  | 中文     |
+----+---------------+----------+
2 rows in set (0.00 sec)
{% endraw %}
{% endhighlight %}

具体流程图如下。可见在被MySQL Server接收到以后实际上已经发生了编码不一致的情况。但是由于Latin1字符集对于自己表述范围外的字符不会做任何处理，而是保留原值。这样的行为也使得错进错出成为了可能。
![flow4](/images/mysql/mojibake/flow4.png)


---


## 如何避免乱码

理解了上面的内容，要避免乱码就显得很容易了。只要做到“三位一体”，即客户端，MySQL character-set-client，table charset三个字符集完全一致就可以保证一定不会有乱码出现了。而对于已经出现乱码，或者已经遭受有损转码的数据，如何修复相对来说就会有些困难。下一节我们详细介绍具体方法。

## 如何修复已经编码损坏的数据

在介绍正确方法前，我们先科普一下那些网上流传的所谓的“正确方法”可能会造成的严重后果。

#### 错误方法一
无论从语法还是字面意思来看：`ALTER TABLE ... CHARSET=xxx` 无疑是最像包治乱码的良药了！而事实上，他对于你已经损坏的数据一点帮助也没有，甚至连已经该表已经创建列的默认字符集都无法改变。我们看下面这个例子
{% highlight mysql %}
{% raw %}
master [localhost] {msandbox} (test) > show create table charset_test;
+--------------+--------------------------------+
| Table        | Create Table                   |
+--------------+--------------------------------+
| charset_test | CREATE TABLE `charset_test` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `char_col` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1 |
+--------------+--------------------------------+
1 row in set (0.00 sec)

master [localhost] {msandbox} (test) > alter table charset_test charset=gbk;
Query OK, 0 rows affected (0.03 sec)
Records: 0  Duplicates: 0  Warnings: 0

master [localhost] {msandbox} (test) > show create table charset_test;
+--------------+--------------------------------+
| Table        | Create Table                   |
+--------------+--------------------------------+
| charset_test | CREATE TABLE `charset_test` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `char_col` varchar(50) CHARACTER SET latin1 DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=gbk |
+--------------+--------------------------------+
1 row in set (0.00 sec)
{% endraw %}
{% endhighlight %}

可见该语法紧紧修改了表的默认字符集，即只对以后创建的列的默认字符集产生影响，而对已经存在的列和数据没有变化。

#### 错误方法二
`ALTER TABLE … CONVERT TO CHARACTER SET … `的相较于方法一来说杀伤力更大，因为从 [官方文档的解释](http://dev.mysql.com/doc/refman/5.1/en/alter-table.html) 他的作用就是用于对一个表的数据进行编码转换。下面是文档的一小段摘录：

>  To change the table default character set and all character columns (CHAR, VARCHAR, TEXT) to a new character set, use a statement like this:
ALTER TABLE tbl_name
CONVERT TO CHARACTER SET charset_name [COLLATE collation_name];

**而实际上，这句语法只适用于当前并没有乱码，并且不是通过`错进错出`的方法保存的表。**{: style="color: red"}。而对于已经因为错进错出而产生编码错误的表，则会带来更糟的结果。我们用一个实际例子来解释下，这句SQL实际做了什么和他会造成的结果。假设我们有一张编码是latin1的表，且之前通过错进错出存入了UTF-8的数据，但是因为通过terminal仍然能够正常显示。即上文错进错出章节中举例的情况。一段时间使用后我们发现了这个错误，并打算把表的字符集编码改成UTF-8并且不影响原有数据的正常显示。这种情况下使用`alter table convert to character set`会有这样的后果：

{% highlight mysql %}
{% raw %}
master [localhost] {msandbox} (test) > create table charset_test_latin1 (id int primary key auto_increment, char_col varchar(50)) charset = latin1;
Query OK, 0 rows affected (0.01 sec)

master [localhost] {msandbox} (test) > set names latin1;
Query OK, 0 rows affected (0.00 sec)

master [localhost] {msandbox} (test) > insert into charset_test_latin1 (char_col) values ('这是中文');
Query OK, 1 row affected (0.01 sec)

master [localhost] {msandbox} (test) > select id,hex(char_col),char_col,char_length(char_col) from charset_test_latin1;
+----+--------------------------+--------------+-----------------------+
| id | hex(char_col)            | char_col     | char_length(char_col) |
+----+--------------------------+--------------+-----------------------+
|  1 | E8BF99E698AFE4B8ADE69687 | 这是中文     |                    12 |
+----+--------------------------+--------------+-----------------------+
1 row in set (0.01 sec)

master [localhost] {msandbox} (test) > alter table charset_test_latin1 convert to character set utf8;
Query OK, 1 row affected (0.04 sec)
Records: 1  Duplicates: 0  Warnings: 0

master [localhost] {msandbox} (test) > set names utf8;
Query OK, 0 rows affected (0.00 sec)

master [localhost] {msandbox} (test) > select id,hex(char_col),char_col,char_length(char_col) from charset_test_latin1;
+----+--------------------------------------------------------+-----------------------------+-----------------------+
| id | hex(char_col)                                          | char_col                    | char_length(char_col) |
+----+--------------------------------------------------------+-----------------------------+-----------------------+
|  1 | C3A8C2BFE284A2C3A6CB9CC2AFC3A4C2B8C2ADC3A6E28093E280A1 | è¿™æ˜¯ä¸­æ–‡                |                    12 |
+----+--------------------------------------------------------+-----------------------------+-----------------------+
1 row in set (0.00 sec)
{% endraw %}
{% endhighlight %}

从这个例子我们可以看出，对于已经错进错出的数据表，这个命令不但没有起到“拨乱反正”的效果，还会彻底将数据糟蹋，连数据的二进制编码都改变了。

#### 正确的方法一 Dump & Reload

这个方法比较笨，但也比较好操作和理解。简单的说分为以下三步：

1. 通过错进错出的方法，导出到文件
2. 用正确的字符集修改新表
3. 将之前导出的文件导回到新表中

还是用上面那个例子举例，我们用UTF-8将数据“错进”到latin1编码的表中。现在需要将表编码修改为UTF-8可以使用以下命令

{% highlight bash %}
{% raw %}
shell> mysqldump -u root -p -t --skip-set-charset --default-character-set=utf8 test charset_test_latin1 > data.sql
#确保导出的文件用文本编辑器在UTF-8编码下查看没有乱码
shell> mysql -uroot -p -e 'create table charset_test_latin1 (id int primary key auto_increment, char_col varchar(50)) charset = utf8' test
shell> mysql -uroot -p  --default-character-set=utf8 test < data.sql
{% endraw %}
{% endhighlight %}


#### 正确的方法二 Convert to Binary & Convert Back

这种方法比较取巧，用的是将二进制数据作为中间数据的做法来实现的。由于，MySQL再将有编码意义的数据流，转换为无编码意义的二进制数据的时候并不做实际的数据转换。而从二进制数据准换为带编码的数据时，又会用目标编码做一次编码转换校验。通过这两个特性就相当于在MySQL内部模拟了一次“错出”，将乱码“拨乱反正”了。

还是用上面那个例子举例，我们用UTF-8将数据“错进”到latin1编码的表中。现在需要将表编码修改为UTF-8可以使用以下命令
{% highlight mysql %}
{% raw %}
mysql> ALTER TABLE charset_test_latin1 MODIFY COLUMN char_col VARBINARY(50);
mysql> ALTER TABLE charset_test_latin1 MODIFY COLUMN char_col varchar(50) character set utf8;
{% endraw %}
{% endhighlight %}



#### Reference

1. <http://www.psce.com/blog/2015/03/03/mysql-character-encoding-part-2/>
2. <http://www.qqxiuzi.cn/zh/hanzi-gbk-bianma.php>
3. <http://zh.wikipedia.org/wiki/%E6%B1%89%E5%AD%97%E5%86%85%E7%A0%81%E6%89%A9%E5%B1%95%E8%A7%84%E8%8C%83>
4. <http://www.qqxiuzi.cn/zh/hanzi-gbk-bianma.php>
5. <http://blog.csdn.net/ws84643557/article/details/6905167>
