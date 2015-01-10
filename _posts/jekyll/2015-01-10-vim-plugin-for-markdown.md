---
layout: article
title:  "vim环境写markdown的插件推荐"
toc: true
#image:
#    teaser: /teaser/disqus_teaser.png
categories: jekyll
---


> 本文将介绍在vim环境写markdown文档或者博文的一些好用插件

## markdown语法高亮及识别

博主使用[vim-markdown](https://github.com/plasticboy/vim-markdown)做语法高亮。安装方法很简单，这里以pathogen为例：
{% highlight bash %}
cd ~/.vim/bundle
git clone https://github.com/plasticboy/vim-markdown.git
{% endhighlight %}

安装完以后plugin自动由pathogen生效，由于我们是用markdown写jekyll博客，这里需要额外对YAML语法做个配置。在`~/.vimrc`中加上以下配置
{% highlight vim %}
let g:vim_markdown_frontmatter=1
{% endhighlight %}



## 代码补全/代码模板（snippet）

博主使用的markdown代码补全工具是[snipMate](https://github.com/garbas/vim-snipmate)工具来源于github。具体安装方式可以见项目的文档，也可以参照下面的摘录的缩略版：
{% highlight bash %}
% cd ~/.vim/bundle
% git clone https://github.com/tomtom/tlib_vim.git
% git clone https://github.com/MarcWeber/vim-addon-mw-utils.git
% git clone https://github.com/garbas/vim-snipmate.git
% git clone https://github.com/honza/vim-snippets.git
{% endhighlight %}
这里比较蛋疼的一点是：*vim-markdown*和*vim-snipmate*无法自动配合使用，目前看来是因为前者将filetype设置为mkd，而后者需要filetype为markdown才能够生效。由于博主不懂vim-script所以用比较粗暴的方式解决了这个问题。如果有哪位读者知道怎么用vimrc或者其他方法解决这个问题的话，欢迎在博文下面留言！
{% highlight bash %}
% cd ~/.vim/bundle/vim-snippets
% cp markdown.snippets mkd.snippets
{% endhighlight %}


### 关于SnipMate还是UltiSnaps

重复造轮是IT界一直在试图避免的事情，那为什么github上会同时存在两个star数量过千代码补全工具呢？关于这个问题vim-snippets的作者正面回答过。简单的总结就是UltiSnaps需要python的支持，这样的依赖显然是不精简的，因此作者写了一套pure vim的解决方案。具体可见以下的摘录：

> Q: Should "snipMate be deprecated in favour of UltiSnips"?
>
> A: No, because snipMate is VimL, and UltiSnips requires Python. Some people want to use snippets without having to install Vim with Python support. Yes - this sucks.
>
> One solution would be: Use snippets if they are good enough, but allow overriding them in UltiSnips. This would avoid most duplication while still serving most users. AFAIK there is a nested-placeholder branch for snipMate too. snipMate is still improved by Adnan Zafar. So maybe time is not ready to make a final decision yet.





