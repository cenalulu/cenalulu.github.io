---
layout: article
title: "程序员高效技巧系列 -- 完全脱离鼠标的终端"
modified:
categories: linux
#excerpt:
#tags: []
image:
#    feature: /teaser/xxx
    teaser: /teaser/tmux_pro.jpg
#    thumb:
date: 2015-05-15T09:44:15-07:00
---


> 本文将介绍如何在tmux窗口管理环境下，不依赖鼠标只通过键盘完成一些常用操作

> 文章欢迎转载，但转载时请保留本段文字，并置于文章的顶部
> 作者：卢钧轶(cenalulu)
> 本文原文地址：<http://cenalulu.github.io{{ page.url }}>


#### 前言

终端(Terminal)无论是程序员还是运维都是Linux平台工作者不可避免的工作环境。如何利用一些神奇的技巧来提高终端的操作效率，无疑会帮助我们省下更多的时间来用于思考。本文将会介绍一些基于tmux终端窗口管理环境下的一些奇巧淫技，来帮助大家完全脱离鼠标工作。如果你还没有听说过tmux或者用过tmux的话，花5分钟时间跟着博主[上一篇入门文章](/linux/tmux/)了解安装下tmux你会发现自己的终端也可以像电影里拍的那么炫。


---


## 复制黏贴

不得不承认无论是开发还是运维，最常用的一个操作之一就是`Ctrl+v`和`Ctrl+c`。在终端下也不可避免的有这样的使用场景：

- 程序运行后打印出了一个Exception，想快速的用grep在代码目录中搜索下这个exception看看是哪里引起的
- 程序打印出了一大段日志，想发给同事看下结果等等

这些情况下想必大家的第一反应是拿起鼠标，选中以后用快捷键复制黏贴，然后手再放回键盘。稍微高效些的作法是配置终端选中后自动复制，免去了一次`Ctrl+c`的操作。但是手臂的运动永远比手指运动要低效，用鼠标选中复制的方法显然不够Hack。况且tmux下，想要选中单个Pane中的文字也是非常蛋疼的。因为不是原生窗体，所以鼠标点击的选中是会横向跨越窗体的（见下图粉色部分）。（注：当然你可以用摁住`⌘+alt`再用鼠标复制，坏处就是你需要手动删除换行前后的空格）。
![copy_crap](/images/linux/tmux_pro/copy_crap.png)
好在tmux的一个重要特性就是支持把整个窗体视作是一个编辑器。换句话说，tmux可以把之前的所有输出都当做是一个文本文档进行选择。再换句话说tmux可以进入一种和vim的Visual模式一样操作体验的字符选择模式。如果你的tmux是和博主[上一篇入门文章](/linux/tmux/)中一样的配置话，无需额外操作就可以进行以下操作。如果没有进行过个性化配置的话，需要将以下部分加到`~/.tmux.conf`中。

{% highlight bash %}
{% raw %}
set-window-option -g mode-keys vi
bind-key -t vi-copy 'v' begin-selection
bind-key -t vi-copy 'y' copy-selection
{% endraw %}
{% endhighlight %}

配置完了`vi-mode`以后，我们就可以通过以下方式进行选择复制黏贴：

- `CTRL+b` + `[`的方式进入选择模式。
- 然后点击`v`键进入`vi-mode`选择模式。
- VIM的移动命令进行选择。也可以使用`CTRL+b` + `:list-keys -t
  vi-copy`查看快捷键列表
- 选择完毕后用`y`复制到tmux剪贴板。或者`ESC`退出选择
- 最后通过`CTRL+b`然后`]`复制到光标所在位置。

下图就是一个选择过程的界面截图，黄色部分为选中的文字。

![copy](/images/linux/tmux_pro/copy.png)


---


## 更快的快捷键 -- 省去prefix

了解screen或者tmux的读者都知道，要进入这两者的操作模式都需要先使用prefix触发。在screen中是`CTRL+a`在tmux中是`CTRL+b`。这也就以为着我如果要新建一个窗体就要`CTRL+b` + `c` 相当于两次键盘操作才能完成。而一些操作系统原生窗体软件，例如ITerm2就只需要`⌘+n`一次键盘操作就能完成。相比之下tmux就显得低效很多。这时有些读者就说了，iTerm2 [深度tmux集成](https://www.iterm2.com/news.html)啊，你为什么不用。博主不用的理由有以下几个：

- 通过`-CC`触发的iTerm2内置tmux时，会额外fork出一个窗口。（即使可以配置自动隐藏，也是非常恼人的）
- iTerm2内置tmux无法做窗体命名
- iTerm2和tmux相关的快捷键无法自定义

综合之下博主决定用其他方式解决tmux快捷键繁琐的问题。此时，博主找到了一篇[iTerm2 keymaps for tmux](http://tangledhelix.com/blog/2012/04/28/iterm2-keymaps-for-tmux/)豁然开朗。发现iTerm2允许把快捷键映射成Hex Code传输给窗体。而tmux的那些快捷键无非就是一串Hex Code的结合。通过查阅 [ASCII和键盘对应表](http://www.cisco.com/c/en/us/td/docs/ios/12_2/configfun/command/reference/ffun_r/frf019.pdf) 我们发现`CTRL b`对应的Hex Code是`0x02`，之后的配置就显得非常简单了。下面是博主的一些快捷键配置清单和截图：

tmux快捷键|映射后快捷键|Hex Code|功能
-|-|-|-
`CTRL+B` `l`|`+l`| 0x02 0x6C|选择右面窗体
`CTRL+B` `k`|`+k`| 0x02 0x6B|选择上方窗体
`CTRL+B` `j`|`+j`| 0x02 0x6A|选择下方窗体
`CTRL+B` `h`|`+h`| 0x02 0x68|选择左面窗体
`CTRL+B` `L`|`+L`| 0x02 0x4C|向右增大窗体大小
`CTRL+B` `H`|`+H`| 0x02 0x48|向右增大窗体大小

由于快捷键较多，且大家的tmux配置都不一样这里就不一一列举。读者可以通过查阅ascii十六进制转换表自行配置，最终的配置截图如下：

![iterm_conf](/images/linux/tmux_pro/iterm_conf.png)


---

## 其他高效Tips

除了纯键盘操作和更精简的快捷键之外，tmux还有很多黑魔法能够提升日常操作的工作效率。

- [VIM和tmux无缝切换](https://github.com/christoomey/vim-tmux-navigator)
- [tmux与系统剪贴板打通](http://evertpot.com/osx-tmux-vim-copy-paste-clipboard/)
- [其他tmux高效tips](https://tylercipriani.com/2013/09/12/important-lines-in-my-tmux.html)



#### Reference

<http://tilvim.com/2014/07/30/tmux-and-vim.html>
[Changing My tmux Command Prefix to Tic](http://zanshin.net/2014/12/27/changing-my-tmux-command-prefix-to-tic/)
[Why invest your time in learning Tmux?](http://minimul.com/teaches/tmux)
[Vi mode in tmux](http://blog.sanctum.geek.nz/vi-mode-in-tmux/)
[ASCII和键盘对应表](http://www.cisco.com/c/en/us/td/docs/ios/12_2/configfun/command/reference/ffun_r/frf019.pdf)
