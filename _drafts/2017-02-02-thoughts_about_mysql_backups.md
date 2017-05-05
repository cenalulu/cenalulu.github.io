---
layout: article
title: MySQL备份验证最佳实践
modified:
categories: mysql
#excerpt:
#tags: []
#image:
#    feature: /teaser/xxx
#    teaser: /teaser/xxx
#    thumb:
date: 2016-03-20T16:54:49+00:00
---



> 文章欢迎转载，但转载时请保留本段文字，并置于文章的顶部
> 作者：卢钧轶(cenalulu)
> 本文原文地址：<http://cenalulu.github.io{{ page.url }}>

### 前言

本文主要是由最近接二连三的类似[GitLab事件](https://about.gitlab.com/2017/02/01/gitlab-dot-com-database-incident/)的发生而有感而生。
主要讨论MySQL备份验证的话题。

## 1. 备份验证的收益

不做恢复演练的备份在需要使用时，很大一定概率是不可用的。所以备份验证对于公司的主要收益是确保备份的可用性。
此外，对于备份验证时的信息的采集也可以帮助我们调整备份策略。例如说，我们经常问的一个问题是：全量备份和增量备份的频率到底应该如何确定？
答案是：可以从两方便综合考虑决定。取决于你对于备份大小和备份恢复时间的预期。

**备份大小**：假设我们每N天进行一次增量备份，那么随着N的增加当
`N * 每天增量备份大小 > 一次全量备份大小`的时候，我们可以得到全备频率应该不低于N

**备份工具化**：如果有了成熟的备份校验框架，那么实际灾难恢复时的操作也简单的很多。大部分是对于备份校验工具的代码和逻辑重用。

**备份恢复速度**：假设我们进行了例行的备份验证，就不难得到备份恢复的时间，和单个增量备份恢复的时间。假设N天进行一次增量备份。那么
`一次全量备份恢复时间 + N * 单个增量备份恢复时间 > 灾难恢复SLA`的时候，我们可以得到全备频率应该不低于每N天一次。这里大家可能会有疑问说，那么灾难恢复SLA如何确定呢？当然让老大拍脑瓜是不科学的。这个SLA可以根据公司实际可承受的不可用时间来决定。例如可以从财务获得公司每分钟的revenue，数据库不可用时间直接造成的就是经济损失。确定一个损失上限显然要比凭空确定一个SLA直观的多。此外不可用时间还影响到公司的公众形象和合作可信度这些非直接经济损失，具体财务和公关都会有较为合适的推导方式。当然这些推导计算缺少了备份恢复时间是没有办法确定备份频度的。


## 2. 备份校验系统的设计

这个可以参考我的同事Divij之前的一篇分享：https://code.facebook.com/posts/1007323976059780/continuous-mysql-backup-validation-restoring-backups/
文章详细介绍了备份校验框架如何设计才能更省资源。

{% highlight bash %}
{% raw %}
>>>str=`
>>>echo ${str: -4}
3307
{% endraw %}
{% endhighlight %}













Reference:
1. <http://wiki.bash-hackers.org/syntax/pe>
2. <http://zsh.sourceforge.net/Doc/Release/Expansion.html#Parameter-Expansion>
3. <http://zshwiki.org/home/scripting/paramflags>



