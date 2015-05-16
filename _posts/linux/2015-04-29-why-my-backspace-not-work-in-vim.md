---
layout: article
title: "Mac的VIM中delete键失效的原因和解决方案"
modified:
categories: linux
#excerpt:
#tags: []
image:
    teaser: /teaser/delete.jpg
#    thumb:
date: 2015-04-29T22:44:12-07:00
---

> 本文介绍叙述Mac上vim中delete键失效的原因和解决方案

> 文章欢迎转载，但转载时请保留本段文字，并置于文章的顶部
> 作者：卢钧轶(cenalulu)
> 本文原文地址：<http://cenalulu.github.io{{ page.url }}>



闲扯：在Mac的键盘上实际是没有`backspace`这个键的。其实Mac的`delete`就是Windows的`backspace`，实现的都是向左删除的功能。Mac上如果要实现向右删除的功能需要使用`⌘+delete`组合键来使用。

## 原因

网上搜到了很多答案但是现象和解决方案都不同，例如：

- [使用`delete`键出现了`^?`](http://stackoverflow.com/questions/8844427/odd-behavior-of-backspace-in-vim-ssh-to-linux-from-mac)
- [使用`delete`键，光标移动，但是字符仍然显示。退回normal模式后字符才彻底消失](http://askubuntu.com/questions/296385/backspace-in-insert-mode-in-vi-doesnt-erase-the-character)
- [使用`delete`键没有反应](http://stackoverflow.com/questions/10727392/vim-not-allowing-backspace)

博主这里遇到的是第三种情况。每次从normal模式再次进入insert模式后，delete就再也无法向左删除。取而代之的是Mac那蛋疼的duang,duang,duang警告声。如果你是伸手党，只想知道怎么解决的话，那么通关密码是在`~/.vimrc`中加上`set backspace=2`。恭喜！你的问题就此解决。（如果问题还在，建议仔细将自己delete键行为和上述三种情况做比对，点击链接对症下药）

博主是个较真且喜欢知道为什么的人。如果你也想知道这个恼人的duang，duang，duang到底是什么原因产生的话，那么让我们往下看。
出现这个问题，基本是因为你的VIM使用了`compatible`模式，或者把`backspace`变量设置为空了。好奇的读者一定会问，这两个配置又代表了什么意思？其实compatible模式是VIM为了兼容vi而出现的配置，它的作用是使VIM的操作行为和规范和vi一致，而这种模式下backspace配置是空的。即意味着backspace无法删除`indent`，`end of line`，`start`这三种字符。如果你出现了和博主一样的情况，不妨在解决问题前先在VIM中用`set backspace?`命令查看下自己当前的删除模式。你会看到如下的情况：
![cmd](/images/linux/vim_on_mac/cmd.png)
![result](/images/linux/vim_on_mac/result.png)

效果就相当于delete只能删除本次insert模式中输入的字符。那么为什么`backspace=2`又能解决问题呢？其实这个命令是`set backspace=indent,eol,start`的简化写法，也就相当于把`delete`键配置成增强模式。具体数值和对应增强模式的对应关系见 [vim官方文档](http://vimdoc.sourceforge.net/htmldoc/options.html#'backspace')，简单摘录如下：

- 0 same as ":set backspace=" (Vi compatible)
- 1 same as ":set backspace=indent,eol"
- 2 same as ":set backspace=indent,eol,start"


#### Reference

1. <http://stackoverflow.com/questions/10727392/vim-not-allowing-backspace?answertab=active#tab-top>
2. <http://unix.stackexchange.com/questions/60057/vim-backspace-not-working-normally>
3. <http://vim.wikia.com/wiki/Backspace_and_delete_problems>
4. <http://askubuntu.com/questions/296385/backspace-in-insert-mode-in-vi-doesnt-erase-the-character>
5. <http://stackoverflow.com/questions/18777705/vim-whats-the-default-backspace-behavior>




