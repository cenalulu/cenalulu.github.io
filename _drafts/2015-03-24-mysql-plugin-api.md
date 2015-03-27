---
layout: article
title: "MySQL Plugin API"
modified:
categories: 
#excerpt:
#tags: []
#image:
#    feature: /teaser/xxx
#    teaser: /teaser/xxx
#    thumb:
date: 2015-03-24T14:48:15+08:00
---



> 文章欢迎转载，但转载时请保留本段文字，并置于文章的顶部
> 作者：卢钧轶(cenalulu)
> 本文原文地址：<http://cenalulu.github.io{{ page.url }}>


## Plugin API

按照[文档](http://dev.mysql.com/doc/refman/5.6/en/plugin-api-characteristics.html)的说法，Plugin API其实和UDF类似。但是，相较于UDF有两个额外优点：

- 有属于Plugin自身的VersionID，方便做Plugin级别的版本兼容。
- 有更强的安全性。Plugin只有从固定位置在MySQL启动时加载，而UDF可以在任何动态链接库的搜索范围内加载。


#### Plugin 种类

MySQL 5.6中支持的Plugin种类有以下几种
- Storage Engine Plugins
- Full-Text Parser Plugins
- Daemon Plugins
- INFORMATION_SCHEMA Plugins
- Semisynchronous Replication Plugins
- Audit Plugins
- Authentication Plugins
- Password-Validation Plugins


#### Full-Text Parser Plugins

用途：主要有两大类用法：

- 用于替代`built-in Parser`，以用于自定义的分词插件，例如中文分词，个性化的英语分词
- 作为`built-in Parser`的前端，用于对字符串的格式化预处理，处理完的字符串将作为输入传入`built-in Parse`进行分词。例如传入字段是XML或者HTML，可以通过Plugin现将格式化数据简化成Plain Text。

注意：目前Full-Text Parser Plugin在5.6及之前都只支持后端存储引擎是MyISAM。在5.7及版本中，[InnoDB也将会以非API形式支持Parser Plugin](https://dev.mysql.com/doc/refman/5.7/en/fulltext-search-ngram.html)





- For this reason, if a plugin library contains a client plugin, the library must have the same basename as that plugin.
- The same is not true for a library that contains server plugins. The --plugin-load option and the INSTALL PLUGIN statement provide the library file name explicitly, so there need be no explicit relationship between the library name and the name of any server plugins it contains.


_mysql_plugin_interface_version_
_mysql_plugin_declarations_
If the server does not find those two symbols in a library, it does not accept it as a legal plugin library and rejects it with an error. 
