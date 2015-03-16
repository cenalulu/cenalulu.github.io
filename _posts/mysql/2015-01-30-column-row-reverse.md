---
layout: article
title:  "MySQL中行列转换的SQL技巧"
categories: mysql
toc: true
ads: true
image:
    teaser: /teaser/row_col_rotate.jpg
---


> 详细介绍MySQL中用SQL实现行列转换的技巧


---


## 行列转换常见场景

由于很多业务表因为历史原因或者性能原因，都使用了违反第一范式的设计模式。即同一个列中存储了多个属性值（具体结构见下表）。 这种模式下，应用常常需要将这个列依据分隔符进行分割，并得到列转行的结果。

表数据：

ID|Value
|-|-|
1|tiny,small,big
2|small,medium
3|tiny,big

期望得到结果：

ID|Value
|-|-|
1|tiny
1|small
1|big
2|small
2|medium
3|tiny
3|big


---


## 具体方法

先从一个具体实例开始我们的介绍：

{% highlight mysql %}
{% raw %}
#准备示例数据
create table tbl_name (ID int ,mSize varchar(100));
insert into tbl_name values (1,'tiny,small,big');
insert into tbl_name values (2,'small,medium');
insert into tbl_name values (3,'tiny,big');

#用于行列转换循环的自增表
create table incre_table (AutoIncreID int);
insert into incre_table values (1);
insert into incre_table values (2);
insert into incre_table values (3);
 

#实现行列转换的SQL
select a.ID,substring_index(substring_index(a.mSize,',',b.AutoIncreID),',',-1) 
from 
tbl_name a
join
incre_table b
on b.AutoIncreID <= (length(a.mSize) - length(replace(a.mSize,',',''))+1)
order by a.ID;
{% endraw %}
{% endhighlight %}


原理分析：
这个join最基本原理是笛卡尔积。通过这个方式来实现循环。
以下是具体问题分析：
`length(a.Size) - length(replace(a.mSize,',',''))+1`  表示了，按照逗号分割后，改列拥有的数值数量，下面简称n
join过程的伪代码：
{% highlight bash %}
{% raw %}
根据ID进行循环
{
    判断：i 是否 <= n
    {
        获取最靠近第 i 个逗号之前的数据， 即 substring_index(substring_index(a.mSize,',',b.ID),',',-1)
        i = i +1 
    }
    ID = ID +1 
}
{% endraw %}
{% endhighlight %}


---


## 改进版本

上面一种方法方法的缺点在于，我们需要一个拥有连续数列的独立表（也就是上文中的`incre_table`)。并且连续数列的最大值一定要大于符合分割的值的个数。 例如有一行的mSize 有100个逗号分割的值，那么我们的`incre_table` 就需要有至少100个连续行。 当然，mysql内部也有现成的连续数列表可用。如`mysql.help_topic`， `help_topic_id` 共有504个数值，一般能满足于大部分需求了。

改写后如下:

{% highlight mysql %}
{% raw %}
select a.ID,substring_index(substring_index(a.mSize,',',b.help_topic_id+1),',',-1) 
from 
tbl_name a
join
mysql.help_topic b
on b.help_topic_id < (length(a.mSize) - length(replace(a.mSize,',',''))+1)
order by a.ID;
{% endraw %}
{% endhighlight %}



 

 

 

 
