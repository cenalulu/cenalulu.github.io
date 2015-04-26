---
layout: article
title: "Tmux - Linux从业者必备利器"
modified:
categories: linux
#excerpt:
#tags: []
image:
    teaser: /teaser/tmux.png
date: 2015-04-25T11:44:13-07:00
---

> 本文详细介绍tmux的概念和搭建过程


> 文章欢迎转载，但转载时请保留本段文字，并置于文章的顶部
> 作者：卢钧轶(cenalulu)
> 本文原文地址：<http://cenalulu.github.io{{ page.url }}>


## tmux

#### 为什么要用tmux

tmux是什么？tmux是linux中一种管理窗口的程序。那么问题来了：Mac自带的Iterm2很好用啊。既支持多标签，也支持窗体内部Panel的分割，为什么还要用tmux？其实，多标签和分割窗体只是tmux的部分功能。用tmux的主要原因是它提供了一个窗体组随时存储和恢复的功能。看看以下的使用场景是否适合你：

- 公司台式机开了一堆vim和log打印窗口下班了。到家后灵感突发，想要继续coding，登陆VPN，SSH连上台式后发现又要重新打开各种窗口，瞬间没心情了。。。FML！这个时候你就可以在你的公司台式机上装个tmux。同一组工作环境，在多处共享。
- 公司服务器上调试程序，开了一堆窗口。出去吃了个饭，发现SSH超时了，`broken pipe`。重头开始。。。FML！如果你之前使用了tmux就不会有这样的问题，attach就能找回原来打开的那些窗口。


---


## tmux的基本概念

我们先来理解下tmux的几个元素。tmux的主要元素分为三层：

- *Session* 一组窗口的集合，通常用来概括同一个任务。session可以有自己的名字便于任务之间的切换。
- *Window* 单个可见窗口。Windows有自己的编号，也可以认为和ITerm2中的Tab类似。
- *Pane* 窗格，被划分成小块的窗口，类似于Vim中 C-w +v 后的效果。

为了更好的理解，下面是三个元素在tmux中的具体展现。

![concept](/images/linux/tmux/concept.jpg)

可以看到Session总在tmux的左下角显示，通常会为他命名。例如我正在写博客，开了很多窗口那么我就会把这组窗口命名为`blog`方便之后的重连和切换。而Window也会在最下方以一种Tab的形式展现。每个window都有自己的需要，也会以当前活动进程的名字命名。而Pane就比较好理解，即把单个窗口分割成若干个小块后的元素。


---


## 安装

本文以Mac环境为例。Linux的方法类似Centos系列的可以用`yum install tmux`安装。

{% highlight bash %}
{% raw %}
brew install tmux
{% endraw %}
{% endhighlight %}

安装完直接执行tmux可能会有以下报错，按照下面的步骤执行命令即可

{% highlight bash %}
{% raw %}
$junyilu> tmux
dyld: Library not loaded: /usr/local/lib/libevent-2.0.5.dylib
Referenced from: /usr/local/Cellar/tmux/1.9a/bin/tmux
Reason: image not found
Trace/BPT trap: 5

$junyilu> brew link libevent
Linking /usr/local/Cellar/libevent/2.0.22...
Error: Could not symlink lib/pkgconfig/libevent.pc
/usr/local/lib/pkgconfig is not writable.

$junyilu> sudo chown junyilu /usr/local/lib/pkgconfig

$junyilu> brew link libevent
Linking /usr/local/Cellar/libevent/2.0.22... 25 symlinks created
{% endraw %}
{% endhighlight %}


---


## tmux的基本操作

`Prefix-Command`前置操作：所有下面介绍的快捷键，都必须以前置操作开始。tmux默认的前置操作是`CTRL+b`。例如，我们想要新建一个窗体，就需要先在键盘上摁下`CTRL+b`，松开后再摁下`n`键。

**下面所有的`prefix`均代表`CTRL+b`**

#### Session相关操作

操作|快捷键
-|-
查看/切换session| prefix s
离开Session| prefix d
重命名当前Session| prefix $


#### Window相关操作

操作|快捷键
-|-
新建窗口|prefix c
切换到上一个活动的窗口|prefix space
关闭一个窗口|prefix &
使用窗口号切换|prefix 窗口号


#### Pane相关操作

操作|快捷键
-|-
切换到下一个窗格|prefix o
查看所有窗格的编号|prefix q
垂直拆分出一个新窗格|prefix "
水平拆分出一个新窗格|prefix %
暂时把一个窗体放到最大|prefix z


---


## tmux的一些个性化定制

默认的tmux风格比较朴素甚至有些丑陋。如果希望做一些美化和个性化配置的话，建议使用[gpakosz的tmux配置](https://github.com/gpakosz/.tmux)。它的本质是一个tmux配置文件，实现了以下功能：

- 基于powerline的美化
- 显示笔记本电池电量
- 和Mac互通的剪切板
- 和vim更相近的快捷键

安装方式也很简单如下 **(注意：如果想使用powerline美化需要先安装powerline，具体方法见[之前的博文](/linux/mac-powerline/))**

{% highlight bash %}
{% raw %}
$ cd
$ rm -rf .tmux
$ git clone https://github.com/gpakosz/.tmux.git
$ ln -s .tmux/.tmux.conf
$ cp .tmux/.tmux.conf.local .
{% endraw %}
{% endhighlight %}

安装完以后就能获得以下效果了：

![powerline](/images/linux/tmux/tmux_screenshot.png)





















